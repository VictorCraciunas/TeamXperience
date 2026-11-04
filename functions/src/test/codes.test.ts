import {test} from "node:test";
import * as assert from "node:assert/strict";
import {
  codeLetters,
  displayCode,
  isWellFormedCode,
  makeCode,
  normaliseCode,
} from "../teams/codes";

test("codeLetters takes the first letter then the next consonants", () => {
  assert.equal(codeLetters("Vulpile"), "VLP");
  assert.equal(codeLetters("Lupii de Cetate"), "LPD");
});

test("codeLetters pads with X and swaps O and I", () => {
  assert.equal(codeLetters("Oaia"), "QXX");
  assert.equal(codeLetters("Ii"), "JXX");
});

test("codeLetters strips Romanian diacritics", () => {
  assert.equal(codeLetters("Țâncii"), "TNC");
  assert.equal(codeLetters("Ăștia"), "AST");
  assert.equal(codeLetters("Șțrumfii"), "STR");
});

test("codeLetters skips vowels after the first letter and pads with X", () => {
  assert.equal(codeLetters("Aeb"), "ABX");
  assert.equal(codeLetters("Ba"), "BXX");
});

test("makeCode appends three digits from 100 to 999", () => {
  assert.equal(makeCode("Vulpile", () => 0), "VLP100");
  assert.equal(makeCode("Vulpile", () => 0.999), "VLP999");
});

test("normaliseCode upper-cases and keeps only letters and digits", () => {
  assert.equal(normaliseCode("vlp 482"), "VLP482");
  assert.equal(normaliseCode(" vlp-482 "), "VLP482");
});

test("isWellFormedCode checks three letters then three digits", () => {
  assert.equal(isWellFormedCode("VLP482"), true);
  assert.equal(isWellFormedCode("vlp-482"), true);
  assert.equal(isWellFormedCode("VL4823"), false);
  assert.equal(isWellFormedCode(""), false);
});

test("displayCode puts a dash between letters and digits", () => {
  assert.equal(displayCode("VLP482"), "VLP-482");
});
