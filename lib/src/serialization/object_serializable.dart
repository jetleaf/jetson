// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

/// {@template json_serializable}
/// Marker interface for all Jetson object (de)serialization components.
///
/// This interface has no methods and exists solely to provide a common
/// supertype for Jetson’s serialization infrastructure. Implementing
/// [ObjectSerializable] indicates that a class participates in Jetson’s
/// serialization pipeline and may be discovered, registered, or applied by:
///
/// - [ObjectSerializer]  
/// - [ObjectDeserializer]  
/// - Converter adapters  
/// - [SerializationContext] / [DeserializationContext]  
/// - Reflection-based or generated serializer lookup
///
/// ### Purpose
/// `Serializable` is used strictly as a semantic marker:
/// - It unifies all Jetson serialization components under a shared type  
/// - It assists the framework in identifying serializable/deserializable
///   handlers during runtime or code generation  
/// - It enables annotation-based discovery and automatic registration
///
/// ### Notes
/// - This interface introduces **zero runtime overhead**  
/// - It does **not** imply that a class is directly serializable as a
///   user-facing model—only that it participates in Jetson’s internal
///   serialization system  
/// - Domain model classes may choose to implement this marker, but it is
///   primarily intended for framework-level components
///
/// {@endtemplate}
abstract interface class ObjectSerializable {
  /// {@macro json_serializable}
  const ObjectSerializable();
}