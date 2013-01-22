/* parser.vala
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

public class XCBVala.Codegen.Parser : Vala.CodeVisitor
{
    // static properties
    private static unowned Parser? s_Default = null;
    private static GLib.StaticPrivate s_SymbolStackKey = GLib.StaticPrivate ();
    private static GLib.StaticPrivate s_SourceStackKey = GLib.StaticPrivate ();

    // properties
    private Vala.CodeContext      m_Context;
    private XmlParser             m_Parser;
    private Vala.Namespace        m_GLibNamespace;

    // static accessors
    public static Parser default {
        get {
            return s_Default;
        }
    }

    // accessors
    public Vala.CodeContext context {
        get {
            return m_Context;
        }
    }

    public Vala.Namespace glib_namespace {
        get {
            return m_GLibNamespace;
        }
    }

    // static methods
    static construct
    {
        XmlObject.register_object ("xcb", typeof (Root));
        XmlObject.register_object ("xidtype", typeof (XidType));
        XmlObject.register_object ("xidunion", typeof (XidUnion));
    }

    public static void
    add_symbol_to_container (Vala.Symbol inContainer, Vala.Symbol inSym)
    {
        if (inContainer is Vala.Class)
        {
            unowned Vala.Class cl = (Vala.Class)inContainer;

            if (inSym is Vala.Class)
                cl.add_class ((Vala.Class)inSym);
            else if (inSym is Vala.Constant)
                cl.add_constant ((Vala.Constant)inSym);
            else if (inSym is Vala.Enum)
                cl.add_enum ((Vala.Enum)inSym);
            else if (inSym is Vala.Field)
                cl.add_field ((Vala.Field)inSym);
            else if (inSym is Vala.Method)
                cl.add_method ((Vala.Method)inSym);
            else if (inSym is Vala.Property)
                cl.add_property ((Vala.Property)inSym);
            else if (inSym is Vala.Signal)
                cl.add_signal ((Vala.Signal)inSym);
            else if (inSym is Vala.Struct)
                cl.add_struct ((Vala.Struct)inSym);
            }
        else if (inContainer is Vala.Enum)
        {
            unowned Vala.Enum en = (Vala.Enum)inContainer;

            if (inSym is Vala.EnumValue)
                en.add_value ((Vala.EnumValue)inSym);
            else if (inSym is Vala.Constant)
                en.add_constant ((Vala.Constant)inSym);
            else if (inSym is Vala.Method)
                en.add_method ((Vala.Method)inSym);
        }
        else if (inContainer is Vala.Interface)
        {
            unowned Vala.Interface iface = (Vala.Interface)inContainer;

            if (inSym is Vala.Class)
                iface.add_class ((Vala.Class)inSym);
            else if (inSym is Vala.Constant)
                iface.add_constant ((Vala.Constant)inSym);
            else if (inSym is Vala.Enum)
                iface.add_enum ((Vala.Enum)inSym);
            else if (inSym is Vala.Field)
                iface.add_field ((Vala.Field)inSym);
            else if (inSym is Vala.Method)
                iface.add_method ((Vala.Method)inSym);
            else if (inSym is Vala.Property)
                iface.add_property ((Vala.Property)inSym);
            else if (inSym is Vala.Signal)
                iface.add_signal ((Vala.Signal)inSym);
            else if (inSym is Vala.Struct)
                iface.add_struct ((Vala.Struct)inSym);
        }
        else if (inContainer is Vala.Namespace)
        {
            unowned Vala.Namespace ns = (Vala.Namespace)inContainer;

            if (inSym is Vala.Namespace)
                ns.add_namespace ((Vala.Namespace)inSym);
            else if (inSym is Vala.Class)
                ns.add_class ((Vala.Class)inSym);
            else if (inSym is Vala.Constant)
                ns.add_constant ((Vala.Constant)inSym);
            else if (inSym is Vala.Delegate)
                ns.add_delegate ((Vala.Delegate)inSym);
            else if (inSym is Vala.Enum)
                ns.add_enum ((Vala.Enum)inSym);
            else if (inSym is Vala.ErrorDomain)
                ns.add_error_domain ((Vala.ErrorDomain)inSym);
            else if (inSym is Vala.Field)
                ns.add_field ((Vala.Field)inSym);
            else if (inSym is Vala.Interface)
                ns.add_interface ((Vala.Interface)inSym);
            else if (inSym is Vala.Method)
                ns.add_method ((Vala.Method)inSym);
            else if (inSym is Vala.Namespace)
                ns.add_namespace ((Vala.Namespace)inSym);
            else if (inSym is Vala.Struct)
                ns.add_struct ((Vala.Struct)inSym);
        }
        else if (inContainer is Vala.Struct)
        {
            unowned Vala.Struct st = (Vala.Struct)inContainer;

            if (inSym is Vala.Constant)
                st.add_constant ((Vala.Constant)inSym);
            else if (inSym is Vala.Field)
                st.add_field ((Vala.Field)inSym);
            else if (inSym is Vala.Method)
                st.add_method ((Vala.Method)inSym);
            else if (inSym is Vala.Property)
                st.add_property ((Vala.Property)inSym);
        }
        else if (inContainer is Vala.ErrorDomain)
        {
            unowned Vala.ErrorDomain ed = (Vala.ErrorDomain)inContainer;

            if (inSym is Vala.ErrorCode)
                ed.add_code ((Vala.ErrorCode)inSym);
            else if (inSym is Vala.Method)
                ed.add_method ((Vala.Method)inSym);
        }
        else
        {
            Vala.Report.error (inSym.source_reference, "impossible to add `%s' to inContainer `%s'".printf (inSym.name, inContainer.name));
        }
    }

    public static Vala.Symbol
    get ()
    {
        Vala.List<Vala.Symbol>* symbol_stack = s_SymbolStackKey.get ();

        return symbol_stack->get (symbol_stack->size - 1);
    }

    public static void
    push (Vala.Symbol inSym)
    {
        Vala.ArrayList<Vala.Symbol>* symbol_stack = s_SymbolStackKey.get ();
        if (symbol_stack == null)
        {
            symbol_stack = new Vala.ArrayList<Vala.CodeContext> ();
            s_SymbolStackKey.set (symbol_stack, null);
        }

        symbol_stack->add (inSym);
    }

    public static void
    pop ()
    {
        Vala.List<Vala.Symbol>* symbol_stack = s_SymbolStackKey.get ();

        symbol_stack->remove_at (symbol_stack->size - 1);
    }

    public static void
    add_symbol (Vala.Symbol inSym)
    {
        add_symbol_to_container (get (), inSym);
    }

    public static Vala.Symbol
    lookup_symbol (string inName)
    {
        return s_Default.m_Context.root.scope.lookup (inName);
    }

    public static Vala.Symbol
    lookup_glib_symbol (string inName)
    {
        return s_Default.m_GLibNamespace.scope.lookup (inName);
    }

    public static Vala.SourceReference
    get_source ()
    {
        Vala.List<Vala.SourceReference>* source_stack = s_SourceStackKey.get ();

        return source_stack->get (source_stack->size - 1);
    }

    public static void
    push_source (Vala.SourceReference inSource)
    {
        Vala.ArrayList<Vala.SourceReference>* source_stack = s_SourceStackKey.get ();
        if (source_stack == null)
        {
            source_stack = new Vala.ArrayList<Vala.SourceReference> ();
            s_SourceStackKey.set (source_stack, null);
        }

        source_stack->add (inSource);
    }

    public static void
    pop_source ()
    {
        Vala.List<Vala.SourceReference>* source_stack = s_SourceStackKey.get ();

        source_stack->remove_at (source_stack->size - 1);
    }

    // methods
    /**
     * Parses all .xml source files in the specified code
     * context and builds a code tree.
     *
     * @param inContext a code context
     */
    public void
    parse (Vala.CodeContext inContext)
    {
        s_Default = this;

        m_Context = inContext;

        m_GLibNamespace = inContext.root.scope.lookup ("GLib") as Vala.Namespace;

        push (m_Context.root);

        m_Context.accept (this);

        pop ();
    }

    public override void
    visit_source_file (Vala.SourceFile inSourceFile)
    {
        if (inSourceFile.filename.has_suffix (".xml"))
        {
            parse_file (inSourceFile);
        }
    }

    public void
    parse_file (Vala.SourceFile inSourceFile)
    {
        message ("Parse %s", inSourceFile.filename);
        var source = new Vala.SourceReference (inSourceFile, { (char*)0, 0, 0 }, { (char*)0, 0, 0 });
        push_source (source);

        var ns = Parser.lookup_symbol ("XcbVala") as Vala.Namespace;

        if (ns == null)
        {
            ns = new Vala.Namespace ("XcbVala", source);
            add_symbol (ns);
        }
        push (ns);

        try
        {
            m_Parser = new XCBVala.XmlParser (inSourceFile.filename);
            m_Parser.parse ("xcb");
        }
        catch (GLib.Error err)
        {
            Vala.Report.error (get_source (), "error on parse: %s".printf (err.message));
        }

        pop ();
        pop_source ();
    }
}
