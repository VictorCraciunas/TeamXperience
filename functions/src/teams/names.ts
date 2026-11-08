export type TeamNameProblem = "short" | "long" | "characters";

/** Trims and collapses inner whitespace. */
export function cleanTeamName(input: string): string {
  return input.trim().replace(/\s+/g, " ");
}

/** What is wrong with the cleaned name, or null when it is fine. */
export function teamNameProblem(name: string): TeamNameProblem | null {
  const cleaned = cleanTeamName(name);
  if (cleaned.length < 2) return "short";
  if (cleaned.length > 30) return "long";
  if (
    cleaned.includes("/") ||
    cleaned.startsWith(".") ||
    cleaned.endsWith(".") ||
    cleaned.includes("__")
  ) {
    return "characters";
  }
  return null;
}

/** The cleaned name lower-cased, for comparing names ignoring case. */
export function nameKey(name: string): string {
  // The old cedilla letters and the right comma ones are the same letter.
  return cleanTeamName(name)
    .toLowerCase()
    .replace(/\u015f/g, "\u0219")
    .replace(/\u0163/g, "\u021b");
}
