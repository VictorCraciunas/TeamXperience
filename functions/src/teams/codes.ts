const VOWELS = "AEIOU";

/** Three upper-case letters that hint at the team name. */
export function codeLetters(teamName: string): string {
  const letters = teamName
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toUpperCase()
    .replace(/[^A-Z]/g, "");

  const picked: string[] = [];
  if (letters.length > 0) {
    picked.push(letters[0]);
    for (const letter of letters.slice(1)) {
      if (picked.length === 3) break;
      if (!VOWELS.includes(letter)) picked.push(letter);
    }
  }
  while (picked.length < 3) picked.push("X");

  return picked
    .join("")
    .replace(/O/g, "Q")
    .replace(/I/g, "J");
}

/** The letters plus three digits from 100 to 999, with no dash. */
export function makeCode(teamName: string, random: () => number): string {
  const digits = 100 + Math.floor(random() * 900);
  return `${codeLetters(teamName)}${digits}`;
}

/** Upper-case, keeping only A-Z and 0-9. */
export function normaliseCode(input: string): string {
  return input.toUpperCase().replace(/[^A-Z0-9]/g, "");
}

export function isWellFormedCode(code: string): boolean {
  return /^[A-Z]{3}[0-9]{3}$/.test(normaliseCode(code));
}

/** "VLP482" becomes "VLP-482". */
export function displayCode(code: string): string {
  return `${code.slice(0, 3)}-${code.slice(3)}`;
}
