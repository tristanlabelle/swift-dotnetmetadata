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

.class public System.Attribute extends System.Object {}
.class public sealed System.TypedReference extends System.ValueType {}
.class public System.Type extends System.Object {}

// Primitive types (intentionally excludes SByte, IntPtr and UIntPtr)
.class public sealed System.Byte extends System.ValueType {}
.class public sealed System.Int16 extends System.ValueType {}
.class public sealed System.UInt16 extends System.ValueType {}
.class public sealed System.Int32 extends System.ValueType {}
.class public sealed System.UInt32 extends System.ValueType {}
.class public sealed System.Int64 extends System.ValueType {}
.class public sealed System.UInt64 extends System.ValueType {}
.class public sealed System.Single extends System.ValueType {}
.class public sealed System.Double extends System.ValueType {}

.class public sealed System.Boolean extends System.ValueType {}
.class public sealed System.Char extends System.ValueType {}
.class public sealed System.Guid extends System.ValueType {}
.class public System.String extends System.Object {}

// Attributes
.class public System.AttributeUsageAttribute extends System.Attribute {}
.class public System.FlagsAttribute extends System.Attribute {}

.class public System.Runtime.InteropServices.GuidAttribute extends System.Attribute {
    .method public hidebysig specialname rtspecialname instance void .ctor(string guid) runtime managed internalcall {}
}

// IActivationFactory interface
.class interface public abstract import windowsruntime System.Runtime.InteropServices.WindowsRuntime.IActivationFactory
{
    // [Guid("00000035-0000-0000-C000-000000000046")]
    .custom instance void System.Runtime.InteropServices.GuidAttribute::.ctor(string) = (
        01 00 24 30 30 30 30 30 30 33 35 2d 30 30 30 30
        2d 30 30 30 30 2d 43 30 30 30 2d 30 30 30 30 30
        30 30 30 30 30 34 36 00 00)
    .method public hidebysig newslot abstract virtual instance object ActivateInstance() cil managed {}
}