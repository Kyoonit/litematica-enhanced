import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

/**
 * First-pass feature inventory for Litematica Enhanced (phase P00).
 *
 * Dependency-free, single-file Java program (JDK 25). Run from the repository root:
 *
 *   java tools/inventory/Inventory.java            # rewrite the generated section of docs/enhanced/registers/features.md
 *   java tools/inventory/Inventory.java --stdout   # print the generated section instead of writing it
 *
 * It extracts, from src/main: config option IDs (with category), hotkey IDs, tool modes, GUI screen
 * classes, client commands and mixin targets. Output is deterministic: no timestamps, files are
 * visited in sorted order, rows are sorted by kind and then by source location.
 * Counts go to standard output; the generated table goes between the BEGIN/END markers.
 */
public class Inventory
{
    static final String BEGIN = "<!-- BEGIN GENERATED: tools/inventory/Inventory.java (do not edit by hand; re-run the script) -->";
    static final String END = "<!-- END GENERATED: tools/inventory/Inventory.java -->";
    static final String SRC = "src/main/java";
    static final String MIXIN_JSON = "src/main/resources/mixins.litematica.json";
    static final String REGISTER = "docs/enhanced/registers/features.md";

    record Row(int kindOrder, String id, String feature, String source, String sortKey) {}
    record ClassDecl(String name, String superSimple, String superFqn, boolean isAbstract, String path, int line) {}
    record JavaFile(String path, String raw, String code, Map<String, String> imports, List<String> wildcards, String pkg) {}

    static final Pattern CONFIG_DECL = Pattern.compile("(\\w+)\\s*=\\s*new\\s+(Config\\w+)\\s*\\(\\s*\"([^\"]+)\"(?:\\s*,\\s*\"([^\"]*)\")?");
    static final Pattern CLASS_DECL = Pattern.compile("((?:(?:public|protected|private|static|final|abstract|sealed|non-sealed)\\s+)*)class\\s+(\\w+)(?:\\s*<[^{]*?>)?\\s+extends\\s+([\\w.]+)");
    static final Pattern ANY_CLASS = Pattern.compile("\\b(?:class|enum|interface|record)\\s+(\\w+)");
    static final Pattern IMPORT = Pattern.compile("(?m)^\\s*import\\s+(?:static\\s+)?([\\w.]+)\\s*;");
    static final Pattern WILDCARD_IMPORT = Pattern.compile("(?m)^\\s*import\\s+([\\w.]+)\\.\\*\\s*;");
    static final Pattern PACKAGE = Pattern.compile("(?m)^\\s*package\\s+([\\w.]+)\\s*;");
    static final Pattern LIST_BLOCK = Pattern.compile("(\\w+)\\s*=\\s*ImmutableList\\.of\\(");
    static final Pattern COMMENTED_CONFIG = Pattern.compile("^\\s*//.*new\\s+(Config\\w+)\\s*\\(\\s*\"([^\"]+)\"");

    public static void main(String[] args) throws IOException
    {
        boolean toStdout = args.length > 0 && args[0].equals("--stdout");
        Path root = Path.of("").toAbsolutePath();

        if (!Files.isDirectory(root.resolve(SRC)))
        {
            System.err.println("Run from the repository root (missing " + SRC + ")");
            System.exit(1);
        }

        List<JavaFile> files = loadJavaFiles(root);
        List<Row> rows = new ArrayList<>();
        List<String> dormant = new ArrayList<>();
        Map<String, Integer> counts = new LinkedHashMap<>();
        Map<String, Integer> configByCategory = new TreeMap<>();

        collectConfigs(files, rows, dormant, counts, configByCategory);
        collectToolModes(files, rows, counts);
        collectScreens(files, rows, counts);
        collectCommands(files, rows, counts);
        List<String> mixinNotes = collectMixins(root, files, rows, counts);

        rows.sort((a, b) -> a.kindOrder() != b.kindOrder() ? Integer.compare(a.kindOrder(), b.kindOrder()) : a.sortKey().compareTo(b.sortKey()));

        String section = render(rows, dormant, counts, configByCategory, mixinNotes);

        if (toStdout)
        {
            // Always UTF-8, whatever the console code page, so the output is byte-identical to the file section.
            System.out.write(section.getBytes(StandardCharsets.UTF_8));
            System.out.flush();
        }
        else
        {
            writeSection(root.resolve(REGISTER), section);
            System.out.println("Updated " + REGISTER);
        }

        System.err.println(countsLine(counts, configByCategory));
    }

    // ---------------------------------------------------------------- loading

    static List<JavaFile> loadJavaFiles(Path root) throws IOException
    {
        List<Path> paths;

        try (Stream<Path> s = Files.walk(root.resolve(SRC)))
        {
            paths = s.filter(p -> p.toString().endsWith(".java")).sorted().toList();
        }

        List<JavaFile> out = new ArrayList<>();

        for (Path p : paths)
        {
            String raw = Files.readString(p, StandardCharsets.UTF_8);
            String code = stripComments(raw);
            Map<String, String> imports = new HashMap<>();
            Matcher m = IMPORT.matcher(code);

            while (m.find())
            {
                String fqn = m.group(1);
                imports.put(fqn.substring(fqn.lastIndexOf('.') + 1), fqn);
            }

            List<String> wildcards = new ArrayList<>();
            Matcher wm = WILDCARD_IMPORT.matcher(code);

            while (wm.find())
            {
                wildcards.add(wm.group(1));
            }

            Matcher pm = PACKAGE.matcher(code);
            String pkg = pm.find() ? pm.group(1) : "";
            out.add(new JavaFile(root.relativize(p).toString().replace('\\', '/'), raw, code, imports, wildcards, pkg));
        }

        return out;
    }

    /** Replaces comment contents with spaces, keeping newlines, so offsets and line numbers stay valid. */
    static String stripComments(String s)
    {
        StringBuilder b = new StringBuilder(s);
        int n = s.length();
        int i = 0;

        while (i < n)
        {
            char c = s.charAt(i);

            if (c == '"' && s.startsWith("\"\"\"", i))
            {
                int end = s.indexOf("\"\"\"", i + 3);
                i = end < 0 ? n : end + 3;
            }
            else if (c == '"' || c == '\'')
            {
                i++;
                while (i < n && s.charAt(i) != c && s.charAt(i) != '\n')
                {
                    i += s.charAt(i) == '\\' ? 2 : 1;
                }
                i++;
            }
            else if (c == '/' && i + 1 < n && s.charAt(i + 1) == '/')
            {
                while (i < n && s.charAt(i) != '\n')
                {
                    if (s.charAt(i) != '\r') b.setCharAt(i, ' ');
                    i++;
                }
            }
            else if (c == '/' && i + 1 < n && s.charAt(i + 1) == '*')
            {
                int end = s.indexOf("*/", i + 2);
                end = end < 0 ? n : end + 2;
                for (int j = i; j < end; j++)
                {
                    if (s.charAt(j) != '\n' && s.charAt(j) != '\r') b.setCharAt(j, ' ');
                }
                i = end;
            }
            else
            {
                i++;
            }
        }

        return b.toString();
    }

    static int lineOf(String s, int offset)
    {
        int line = 1;
        for (int i = 0; i < offset && i < s.length(); i++)
        {
            if (s.charAt(i) == '\n') line++;
        }
        return line;
    }

    static String loc(JavaFile f, int offset)
    {
        return f.path() + ":" + lineOf(f.code(), offset);
    }

    static String sortKey(String path, int line)
    {
        return path + "#" + String.format("%06d", line);
    }

    /** Name of the closest class/enum/interface declared before the offset (good enough for the flat nested classes of Configs). */
    static String enclosingClass(JavaFile f, int offset)
    {
        Matcher m = ANY_CLASS.matcher(f.code());
        String name = "?";
        while (m.find() && m.start() < offset)
        {
            name = m.group(1);
        }
        return name;
    }

    // ---------------------------------------------------------------- configs and hotkeys

    static void collectConfigs(List<JavaFile> files, List<Row> rows, List<String> dormant, Map<String, Integer> counts, Map<String, Integer> byCategory)
    {
        int configs = 0, hotkeys = 0, hotkeyedConfigs = 0, notListed = 0;

        for (JavaFile f : files)
        {
            Matcher m = CONFIG_DECL.matcher(f.code());

            while (m.find())
            {
                String field = m.group(1);
                String type = m.group(2);
                String id = m.group(3);
                String category = enclosingClass(f, m.start());
                boolean listed = isListed(f, field, category);
                int line = lineOf(f.code(), m.start());
                String listNote = listed ? "" : "; not in any `ImmutableList.of(...)` list of `" + category + "`";

                if (type.equals("ConfigHotkey"))
                {
                    hotkeys++;
                    String def = m.group(4) == null ? "" : ", default `" + (m.group(4).isEmpty() ? "none" : m.group(4)) + "`";
                    rows.add(new Row(2, "EX-HK-" + id, "Hotkey `" + id + "` (" + category + def + ")" + listNote, f.path() + ":" + line, sortKey(f.path(), line)));
                }
                else
                {
                    configs++;
                    if (type.equals("ConfigBooleanHotkeyed")) hotkeyedConfigs++;
                    byCategory.merge(category, 1, Integer::sum);
                    rows.add(new Row(1, "EX-CFG-" + category + "." + id, "Config option `" + id + "` (" + category + ", " + type + ")" + listNote, f.path() + ":" + line, sortKey(f.path(), line)));
                }

                if (!listed) notListed++;
            }

            String[] lines = f.raw().split("\n", -1);
            for (int i = 0; i < lines.length; i++)
            {
                Matcher d = COMMENTED_CONFIG.matcher(lines[i]);
                if (d.find())
                {
                    dormant.add("| `" + d.group(2) + "` | " + d.group(1) + " | " + f.path() + ":" + (i + 1) + " |");
                }
            }
        }

        counts.put("config options", configs);
        counts.put("  of which ConfigBooleanHotkeyed (also bindable)", hotkeyedConfigs);
        counts.put("hotkeys (ConfigHotkey)", hotkeys);
        counts.put("declarations not in an ImmutableList.of(...) list", notListed);
        counts.put("commented-out config declarations (dormant, not counted)", dormant.size());
    }

    /** True if the field name appears in an ImmutableList.of(...) block located inside the same (flat) nested class. */
    static boolean isListed(JavaFile f, String field, String category)
    {
        Matcher lm = LIST_BLOCK.matcher(f.code());
        Pattern word = Pattern.compile("\\b" + Pattern.quote(field) + "\\b");

        while (lm.find())
        {
            if (!enclosingClass(f, lm.start()).equals(category)) continue;
            int end = matchingParen(f.code(), lm.end() - 1);
            if (word.matcher(f.code().substring(lm.end(), end)).find()) return true;
        }

        return false;
    }

    static int matchingParen(String s, int open)
    {
        int depth = 0;
        for (int i = open; i < s.length(); i++)
        {
            char c = s.charAt(i);
            if (c == '(') depth++;
            else if (c == ')' && --depth == 0) return i;
        }
        return s.length();
    }

    // ---------------------------------------------------------------- tool modes

    static void collectToolModes(List<JavaFile> files, List<Row> rows, Map<String, Integer> counts)
    {
        int n = 0;
        Pattern constant = Pattern.compile("\\b([A-Z][A-Z0-9_]*)\\s*\\(\\s*\"([^\"]*)\"");

        for (JavaFile f : files)
        {
            Matcher em = Pattern.compile("\\benum\\s+ToolMode\\b[^{]*\\{").matcher(f.code());
            if (!em.find()) continue;

            int bodyStart = em.end();
            int bodyEnd = constantsEnd(f.code(), bodyStart);
            Matcher cm = constant.matcher(f.code());
            cm.region(bodyStart, bodyEnd);

            while (cm.find())
            {
                int line = lineOf(f.code(), cm.start());
                rows.add(new Row(3, "EX-TOOL-" + cm.group(1), "Tool mode `" + cm.group(1) + "` (`" + cm.group(2) + "`)", f.path() + ":" + line, sortKey(f.path(), line)));
                n++;
            }
        }

        counts.put("tool modes", n);
    }

    /** End of an enum's constant list: the first ';' at parenthesis depth 0. */
    static int constantsEnd(String s, int from)
    {
        int depth = 0;
        for (int i = from; i < s.length(); i++)
        {
            char c = s.charAt(i);
            if (c == '(') depth++;
            else if (c == ')') depth--;
            else if (c == ';' && depth == 0) return i;
            else if (c == '"')
            {
                i++;
                while (i < s.length() && s.charAt(i) != '"') i += s.charAt(i) == '\\' ? 2 : 1;
            }
        }
        return s.length();
    }

    // ---------------------------------------------------------------- GUI screens

    static boolean isScreenRoot(String fqn)
    {
        if (fqn == null) return false;
        String simple = fqn.substring(fqn.lastIndexOf('.') + 1);
        return (fqn.startsWith("fi.dy.masa.malilib.gui.") && !fqn.contains(".widgets.") && simple.startsWith("Gui"))
                || fqn.equals("net.minecraft.client.gui.screens.Screen");
    }

    static void collectScreens(List<JavaFile> files, List<Row> rows, Map<String, Integer> counts)
    {
        Map<String, ClassDecl> decls = new TreeMap<>();
        Set<String> repoClasses = new TreeSet<>();

        for (JavaFile f : files)
        {
            Matcher any = ANY_CLASS.matcher(f.code());
            while (any.find()) repoClasses.add(any.group(1));
        }

        for (JavaFile f : files)
        {
            Matcher m = CLASS_DECL.matcher(f.code());
            while (m.find())
            {
                String sup = m.group(3);
                String superSimple = sup.substring(sup.lastIndexOf('.') + 1);
                String superFqn = sup.contains(".") ? sup : f.imports().get(superSimple);

                // Not imported explicitly and not a repository class: resolve through wildcard imports.
                if (superFqn == null && !repoClasses.contains(superSimple))
                {
                    for (String w : f.wildcards())
                    {
                        if (isScreenRoot(w + "." + superSimple))
                        {
                            superFqn = w + "." + superSimple;
                            break;
                        }
                    }
                }

                decls.put(m.group(2), new ClassDecl(m.group(2), superSimple, superFqn, m.group(1).contains("abstract"), f.path(), lineOf(f.code(), m.start())));
            }
        }

        Set<String> screens = new TreeSet<>();
        boolean changed = true;

        while (changed)
        {
            changed = false;
            for (ClassDecl d : decls.values())
            {
                if (screens.contains(d.name())) continue;
                boolean repoSuper = d.superFqn() == null || d.superFqn().startsWith("fi.dy.masa.litematica.");
                if (isScreenRoot(d.superFqn()) || (repoSuper && screens.contains(d.superSimple())))
                {
                    screens.add(d.name());
                    changed = true;
                }
            }
        }

        int concrete = 0, abstracts = 0;

        for (String name : screens)
        {
            ClassDecl d = decls.get(name);
            if (d.isAbstract()) abstracts++; else concrete++;
            rows.add(new Row(4, "EX-GUI-" + name, "GUI screen `" + name + "`" + (d.isAbstract() ? " (abstract)" : "") + ", extends `" + d.superSimple() + "`", d.path() + ":" + d.line(), sortKey(d.path(), d.line())));
        }

        counts.put("GUI screen classes", screens.size());
        counts.put("  concrete", concrete);
        counts.put("  abstract", abstracts);
    }

    // ---------------------------------------------------------------- commands

    static void collectCommands(List<JavaFile> files, List<Row> rows, Map<String, Integer> counts)
    {
        int n = 0;
        Pattern getCommand = Pattern.compile("getCommand\\s*\\(\\s*\\)\\s*\\{\\s*return\\s+\"([^\"]+)\"");
        Pattern sub = Pattern.compile("equalsIgnoreCase\\(\\s*\"([^\"]+)\"\\s*\\)");
        Pattern registration = Pattern.compile("registerCommand\\s*\\(\\s*new\\s+(\\w+)");
        Set<String> registered = new TreeSet<>();

        for (JavaFile f : files)
        {
            Matcher r = registration.matcher(f.code());
            while (r.find()) registered.add(r.group(1) + " @ " + loc(f, r.start()));
        }

        for (JavaFile f : files)
        {
            if (!f.code().contains("IClientCommandListener")) continue;
            Matcher m = getCommand.matcher(f.code());

            while (m.find())
            {
                Set<String> subs = new LinkedHashSet<>();
                Matcher sm = sub.matcher(f.code());
                while (sm.find()) subs.add(sm.group(1));

                String cls = f.path().substring(f.path().lastIndexOf('/') + 1).replace(".java", "");
                String reg = registered.stream().filter(s -> s.startsWith(cls + " @ ")).map(s -> s.substring(cls.length() + 3)).findFirst().orElse("not found");
                int line = lineOf(f.code(), m.start());
                String name = m.group(1);
                rows.add(new Row(5, "EX-CMD-" + name.replace("#", "").replace("/", ""), "Client command `" + name + "` (`" + cls + "`; sub-commands: " + (subs.isEmpty() ? "none" : String.join(", ", subs)) + "; registered at " + reg + ")", f.path() + ":" + line, sortKey(f.path(), line)));
                n++;
            }
        }

        counts.put("client commands", n);
    }

    // ---------------------------------------------------------------- mixins

    static List<String> collectMixins(Path root, List<JavaFile> files, List<Row> rows, Map<String, Integer> counts) throws IOException
    {
        String json = Files.readString(root.resolve(MIXIN_JSON), StandardCharsets.UTF_8);
        Matcher pm = Pattern.compile("\"package\"\\s*:\\s*\"([^\"]+)\"").matcher(json);
        String basePkg = pm.find() ? pm.group(1) : "fi.dy.masa.litematica.mixin";
        Map<String, String> envByMixin = new HashMap<>();

        for (String env : List.of("mixins", "client", "server"))
        {
            Matcher am = Pattern.compile("\"" + env + "\"\\s*:\\s*\\[(.*?)\\]", Pattern.DOTALL).matcher(json);
            if (!am.find()) continue;
            Matcher sm = Pattern.compile("\"([^\"]+)\"").matcher(am.group(1));
            while (sm.find()) envByMixin.put(sm.group(1), env.equals("mixins") ? "common" : env);
        }

        Pattern mixinAnn = Pattern.compile("@Mixin\\s*\\(");
        Pattern classLit = Pattern.compile("([\\w.]+)\\.class");
        Pattern targetsStr = Pattern.compile("targets\\s*=\\s*\\{?\\s*((?:\"[^\"]+\"\\s*,?\\s*)+)\\}?");
        Set<String> distinctTargets = new TreeSet<>();
        Set<String> found = new TreeSet<>();
        int injections = 0;

        for (JavaFile f : files)
        {
            Matcher m = mixinAnn.matcher(f.code());
            if (!m.find()) continue;

            int end = matchingParen(f.code(), m.end() - 1);
            String args = f.code().substring(m.end(), end);
            List<String> targets = new ArrayList<>();
            Matcher cm = classLit.matcher(args);

            while (cm.find())
            {
                String t = cm.group(1);
                String simple = t.substring(t.lastIndexOf('.') + 1);
                String fqn = t.contains(".") ? t : f.imports().getOrDefault(simple, simple);
                targets.add(fqn);
            }

            Matcher tm = targetsStr.matcher(args);
            if (tm.find())
            {
                Matcher q = Pattern.compile("\"([^\"]+)\"").matcher(tm.group(1));
                while (q.find()) targets.add(q.group(1));
            }

            String cls = f.path().substring(f.path().lastIndexOf('/') + 1).replace(".java", "");
            String rel = f.pkg().startsWith(basePkg + ".") ? f.pkg().substring(basePkg.length() + 1) + "." + cls : (f.pkg().equals(basePkg) ? cls : f.pkg() + "." + cls);
            found.add(rel);
            distinctTargets.addAll(targets);

            Matcher inj = Pattern.compile("@(Inject|Redirect|ModifyArg|ModifyArgs|ModifyVariable|ModifyConstant|ModifyExpressionValue|ModifyReturnValue|WrapOperation|WrapWithCondition|Overwrite)\\b").matcher(f.code());
            int fileInjections = 0;
            while (inj.find()) fileInjections++;
            injections += fileInjections;

            String env = envByMixin.getOrDefault(rel, "NOT IN " + MIXIN_JSON.substring(MIXIN_JSON.lastIndexOf('/') + 1));
            int line = lineOf(f.code(), m.start());
            rows.add(new Row(6, "EX-MIX-" + rel, "Mixin `" + rel + "` (" + env + ", " + fileInjections + " injector annotations) → " + String.join(", ", targets.stream().map(t -> "`" + t + "`").toList()), f.path() + ":" + line, sortKey(f.path(), line)));
        }

        List<String> notes = new ArrayList<>();
        for (String listed : new TreeSet<>(envByMixin.keySet()))
        {
            if (!found.contains(listed)) notes.add("Listed in `" + MIXIN_JSON + "` but no `@Mixin` class found: `" + listed + "`");
        }

        counts.put("mixin classes (@Mixin)", found.size());
        counts.put("mixin entries in mixins.litematica.json", envByMixin.size());
        counts.put("distinct mixin targets", distinctTargets.size());
        counts.put("injector annotations (@Inject/@Redirect/@Modify*/@Wrap*/@Overwrite)", injections);
        return notes;
    }

    // ---------------------------------------------------------------- output

    static String countsLine(Map<String, Integer> counts, Map<String, Integer> byCategory)
    {
        StringBuilder b = new StringBuilder("Counts:");
        counts.forEach((k, v) -> b.append("\n  ").append(k).append(": ").append(v));
        b.append("\n  config options by category: ").append(byCategory);
        return b.toString();
    }

    static String render(List<Row> rows, List<String> dormant, Map<String, Integer> counts, Map<String, Integer> byCategory, List<String> mixinNotes)
    {
        StringBuilder b = new StringBuilder();
        b.append(BEGIN).append("\n");
        b.append("## Existing-feature inventory (first pass, generated)\n\n");
        b.append("Generated from `src/main` by `java tools/inventory/Inventory.java` (run from the repository root). ");
        b.append("Kind `existing`, status `unassessed`; P02 assesses each row (journey, fairness class, cost, value, upstream category).\n\n");
        b.append("| Count | Value |\n|---|---|\n");
        counts.forEach((k, v) -> b.append("| ").append(k.strip()).append(k.startsWith("  ") ? " (subset)" : "").append(" | ").append(v).append(" |\n"));
        b.append("| config options by category | ");
        b.append(String.join(", ", byCategory.entrySet().stream().map(e -> e.getKey() + " " + e.getValue()).toList()));
        b.append(" |\n\n");
        b.append("| ID | Feature | Kind (existing/new) | Journey | Status | Fairness class | Cost | Value score | Upstream cat. | Spec | Phase | Source |\n");
        b.append("|---|---|---|---|---|---|---|---|---|---|---|---|\n");

        for (Row r : rows)
        {
            b.append("| ").append(r.id()).append(" | ").append(r.feature().replace("|", "\\|")).append(" | existing | — | unassessed | — | — | — | — | — | P02 | ").append(r.source()).append(" |\n");
        }

        b.append("\n### Dormant config declarations (commented out in the source; not counted above)\n\n");
        b.append("| Option ID | Type | Source |\n|---|---|---|\n");
        dormant.forEach(d -> b.append(d).append("\n"));

        if (!mixinNotes.isEmpty())
        {
            b.append("\n### Mixin configuration notes\n\n");
            mixinNotes.forEach(n -> b.append("- ").append(n).append("\n"));
        }

        b.append(END).append("\n");
        return b.toString();
    }

    static void writeSection(Path register, String section) throws IOException
    {
        String original = Files.exists(register) ? Files.readString(register, StandardCharsets.UTF_8) : null;
        // Keep the file's own line endings (CRLF in a core.autocrlf=true checkout), so a rerun
        // leaves `git status` clean (AUD-P00-06).
        String eol = original != null && original.contains("\r\n") ? "\r\n" : "\n";
        String text = original != null ? original.replace("\r\n", "\n") : "# Feature register (inventory + backlog)\n\n";
        int begin = text.indexOf(BEGIN);
        int end = text.indexOf(END);
        String updated;

        if (begin >= 0 && end > begin)
        {
            updated = text.substring(0, begin) + section + text.substring(end + END.length() + (text.startsWith("\n", end + END.length()) ? 1 : 0));
        }
        else
        {
            updated = (text.endsWith("\n") ? text : text + "\n") + "\n" + section;
        }

        Files.writeString(register, eol.equals("\n") ? updated : updated.replace("\n", eol), StandardCharsets.UTF_8);
    }
}
