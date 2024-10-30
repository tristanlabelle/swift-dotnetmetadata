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

// Primitive types
.class public sealed System.Byte extends System.ValueType {}
.class public sealed System.SByte extends System.ValueType {} // Not used by WinRT
.class public sealed System.Int16 extends System.ValueType {}
.class public sealed System.UInt16 extends System.ValueType {}
.class public sealed System.Int32 extends System.ValueType {}
.class public sealed System.UInt32 extends System.ValueType {}
.class public sealed System.Int64 extends System.ValueType {}
.class public sealed System.UInt64 extends System.ValueType {}
.class public sealed System.IntPtr extends System.ValueType {} // Not used by WinRT
.class public sealed System.UIntPtr extends System.ValueType {} // Not used by WinRT
.class public sealed System.Single extends System.ValueType {}
.class public sealed System.Double extends System.ValueType {}

.class public sealed System.Boolean extends System.ValueType {}
.class public sealed System.Char extends System.ValueType {}
.class public sealed System.Guid extends System.ValueType {}
.class public System.String extends System.Object {}

// Attributes
.class public System.AttributeUsageAttribute extends System.Attribute {}
.class public System.FlagsAttribute extends System.Attribute {}