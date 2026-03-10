/// Enum representing the current status of a 3D print request.
enum PrintStatus {
  pending,
  approved,
  printing,
  done,
  rejected,
}

/// Enum representing the priority level of a request.
enum Priority {
  low,
  normal,
  high,
}

/// Enum representing available 3D printers.
enum PrinterType {
  bambuLabP1S,
  ender3,
  flashforgeAdventurer,
  other,
}

/// Enum representing available print materials.
enum MaterialType {
  pla,
  petg,
  tpu,
  abs,
  other,
}
