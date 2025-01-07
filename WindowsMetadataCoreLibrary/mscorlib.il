// A dummy mscorlib reference assembly that defines only what is referenced by Windows Metadata files.
.mscorlib

.assembly windowsruntime mscorlib
{
    .ver 255:255:255:255
}

.module mscorlib.winmd
.imagebase 0x00400000
.file alignment 0x00000200
.subsystem 0x0003 // WindowsCui
.corflags 0x00000001 // ILOnly

// Type system and core types
.class public System.Object {}
.class public abstract System.ValueType extends System.Object {}
.class public abstract System.Enum extends System.ValueType {}
.class public sealed System.Void extends System.ValueType {}
.class public System.Delegate extends System.Object {}
.class public System.MulticastDelegate extends System.Delegate {}
.class public System.Array extends System.Object {}
.class public sealed System.TypedReference extends System.ValueType {}
.class public System.Type extends System.Object {}

// Attributes
.class public System.Attribute extends System.Object {}

.class public auto ansi sealed serializable System.AttributeTargets extends System.Enum
{
	.field public specialname rtspecialname int32 value__
}

.class public System.AttributeUsageAttribute extends System.Attribute
{
    .method public hidebysig specialname rtspecialname instance
        void .ctor(valuetype System.AttributeTargets validOn)
        runtime managed internalcall {}

    .method public hidebysig specialname rtspecialname instance
        void .ctor(valuetype System.AttributeTargets validOn, bool allowMultiple, bool inherited)
        runtime managed internalcall {}

    .method public hidebysig specialname instance void set_AllowMultiple(bool 'value') runtime managed internalcall {}
    .property instance bool AllowMultiple()
    {
        .set instance void System.AttributeUsageAttribute::set_AllowMultiple(bool)
    }

    .method public hidebysig specialname instance void set_Inherited(bool 'value') runtime managed internalcall {}
    .property instance bool Inherited()
    {
        .set instance void System.AttributeUsageAttribute::set_Inherited(bool)
    }
}

.class public System.FlagsAttribute extends System.Attribute
{
    .method public hidebysig specialname rtspecialname instance void .ctor() runtime managed internalcall {}
}

// Primitive types
.class public sealed System.Boolean extends System.ValueType {}
.class public sealed System.Char extends System.ValueType {}
.class public sealed System.Byte extends System.ValueType {}
.class public sealed System.Int16 extends System.ValueType {}
.class public sealed System.UInt16 extends System.ValueType {}
.class public sealed System.Int32 extends System.ValueType {}
.class public sealed System.UInt32 extends System.ValueType {}
.class public sealed System.Int64 extends System.ValueType {}
.class public sealed System.UInt64 extends System.ValueType {}
.class public sealed System.Single extends System.ValueType {}
.class public sealed System.Double extends System.ValueType {}

.class public sealed System.Guid extends System.ValueType {}
.class public System.String extends System.Object {}

// WinRT does not expose System.IntPtr as a type, but it appears
// internally in the metadata for delegates: .ctor(object, native int)
.class public sealed System.IntPtr extends System.ValueType {}
