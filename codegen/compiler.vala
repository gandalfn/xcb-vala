/* compiler.vala
 *
 * Copyright (C) 2012  Nicolas Bruguier
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *  Nicolas Bruguier <nicolas.bruguier@supersonicimagine.fr>
 */

using GLib;

public class XCBVala.Codegen.Compiler
{
    // constants
    private const OptionEntry[] c_Options = {
        { "vapidir", 0, 0, OptionArg.FILENAME_ARRAY, ref s_VapiDirectories, "Look for package bindings in DIRECTORY", "DIRECTORY..." },
        { "pkg", 0, 0, OptionArg.STRING_ARRAY, ref s_Packages, "Include binding for PACKAGE", "PACKAGE..." },
        { "", 0, 0, OptionArg.FILENAME_ARRAY, ref s_Sources, null, "FILE..." },
        { null }
    };

    // static properties
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] s_Sources;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] s_VapiDirectories;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] s_Packages;

    // properties
    private Vala.CodeContext m_Context;

    // methods
    private int
    quit () {
        if (m_Context.report.get_errors () == 0 && m_Context.report.get_warnings () == 0)
        {
            return 0;
        }
        if (m_Context.report.get_errors () == 0)
        {
            stdout.printf ("Compilation succeeded - %d warning(s)\n", m_Context.report.get_warnings ());
            return 0;
        }
        else
        {
            stdout.printf ("Compilation failed: %d error(s), %d warning(s)\n", m_Context.report.get_errors (), m_Context.report.get_warnings ());
            return 1;
        }
    }

    private int
    run ()
    {
        m_Context = new Vala.CodeContext ();
        Vala.CodeContext.push (m_Context);

        m_Context.assert = true;
        m_Context.checking = false;
        m_Context.deprecated = false;
        m_Context.experimental = false;
        m_Context.experimental_non_null = false;
        m_Context.gobject_tracing = false;
        m_Context.report.enable_warnings = true;
        m_Context.report.set_verbose_errors (true);
        m_Context.verbose_mode = false;
        m_Context.version_header = true;

        m_Context.ccode_only = true;
        m_Context.compile_only = false;
        m_Context.header_filename = "xcb-vala.h";
        m_Context.use_header = true;
        m_Context.internal_header_filename = null;
        m_Context.symbols_filename = null;
        m_Context.includedir = null;
        m_Context.output = "xcb-vala.c";
        m_Context.basedir = Vala.CodeContext.realpath (".");
        m_Context.directory = m_Context.basedir;
        m_Context.vapi_directories = s_VapiDirectories;
        m_Context.gir_directories = null;
        m_Context.metadata_directories = null;
        m_Context.debug = false;
        m_Context.thread = true;
        m_Context.mem_profiler = false;
        m_Context.save_temps = false;

        m_Context.profile = Vala.Profile.GOBJECT;
        m_Context.add_define ("GOBJECT");

        m_Context.nostdpkg = false;

        m_Context.entry_point_name = null;

        m_Context.run_output = false;

        for (int i = 2; i <= 20; i += 2)
        {
            m_Context.add_define ("VALA_0_%d".printf (i));
        }

        m_Context.target_glib_major = 2;
        m_Context.target_glib_minor = 32;

        for (int i = 16; i <= 32; i += 2)
        {
            m_Context.add_define ("GLIB_2_%d".printf (i));
        }

        /* default packages */
        m_Context.add_external_package ("glib-2.0");
        m_Context.add_external_package ("gobject-2.0");

        if (s_Packages != null)
        {
            foreach (string package in s_Packages)
            {
                m_Context.add_external_package (package);
            }
            s_Packages = null;
        }

        if (m_Context.report.get_errors () > 0 )
        {
            return quit ();
        }

        foreach (string source in s_Sources)
        {
            message ("Add source %s", source);
            m_Context.add_source_filename (source, true, true);
        }

        if (m_Context.report.get_errors () > 0)
        {
            return quit ();
        }

        m_Context.codegen = new Vala.GDBusServerModule ();

        var vparser = new Vala.Parser ();
        vparser.parse (m_Context);

        var parser = new Parser ();
        parser.parse (m_Context);

        if (m_Context.report.get_errors () > 0)
        {
            return quit ();
        }

        m_Context.check ();

        if (m_Context.report.get_errors () > 0)
        {
            return quit ();
        }

        m_Context.codegen.emit (m_Context);

        if (m_Context.report.get_errors () > 0)
        {
            return quit ();
        }

        var interface_writer = new Vala.CodeWriter ();
        interface_writer.write_file (m_Context, "xcb-vala.vapi");

        return quit ();
    }

    static int
    main (string[] args)
    {
        // initialize locale
        Intl.setlocale (LocaleCategory.ALL, "");

        try
        {
            var opt_context = new OptionContext ("- Vala Compiler");
            opt_context.set_help_enabled (true);
            opt_context.add_main_entries (c_Options, null);
            opt_context.parse (ref args);
        }
        catch (OptionError e)
        {
            stdout.printf ("%s\n", e.message);
            stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return 1;
        }

        var compiler = new Compiler ();
        return compiler.run ();
    }
}
