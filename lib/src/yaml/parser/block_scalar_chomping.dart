/// Represents the **chomping behavior** for YAML block scalars (`|` and `>`).
///
/// YAML block scalars allow control over how trailing newline characters
/// are handled. Chomping determines how many of those newlines should be kept,
/// removed, or normalized.
///
/// ### YAML Reference
/// In YAML, chomping indicators appear as:
/// - `|`, `>` (implicit *clip*)
/// - `|+`, `>+` (*keep*)
/// - `|-`, `>-` (*strip*)
///
/// ### Behaviors
/// - **CLIP (`|` / `>`)**  
///   *Default behavior.*  
///   Retains **exactly one** trailing newline, regardless of how many were in
///   the source block. Extra trailing newlines beyond one are removed.
///
/// - **KEEP (`|+` / `>+`)**  
///   Preserves **all** trailing newlines exactly as written in the block
///   scalar. Nothing is removed.
///
/// - **STRIP (`|-` / `>-`)**  
///   Removes **all** trailing newlines from the block scalar output.
///
/// This enum is used by YAML serializers and parsers to correctly interpret
/// block scalar formatting rules.
enum BlockScalarChomping {
  /// Default chomping mode:
  /// retains exactly **one** trailing newline.
  CLIP,

  /// Keeps **all** trailing newlines exactly as written.
  KEEP,

  /// Removes **all** trailing newlines.
  STRIP,
}