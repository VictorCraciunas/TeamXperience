import {test} from "node:test";
import * as assert from "node:assert/strict";
import {cleanTeamName, nameKey, teamNameProblem} from "../teams/names";

test("cleanTeamName trims and collapses inner spaces", () => {
  assert.equal(cleanTeamName("  Lupii   de  Cetate "), "Lupii de Cetate");
});

test("teamNameProblem flags short names", () => {
  assert.equal(teamNameProblem("A"), "short");
  assert.equal(teamNameProblem(""), "short");
});

test("teamNameProblem flags long names", () => {
  assert.equal(teamNameProblem("a".repeat(31)), "long");
  assert.equal(teamNameProblem("a".repeat(30)), null);
});

test("teamNameProblem flags characters Firestore ids cannot take", () => {
  assert.equal(teamNameProblem("A/B"), "characters");
  assert.equal(teamNameProblem(".."), "characters");
  assert.equal(teamNameProblem(".ab"), "characters");
  assert.equal(teamNameProblem("ab."), "characters");
  assert.equal(teamNameProblem("a__b"), "characters");
});

test("teamNameProblem accepts a normal name", () => {
  assert.equal(teamNameProblem("Vulpile"), null);
});

test("nameKey ignores case and surrounding spaces", () => {
  assert.equal(nameKey(" Vulpile "), nameKey("VULPILE"));
});
