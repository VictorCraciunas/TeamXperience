import {describe, test} from "node:test";
import * as assert from "node:assert/strict";
import {sendsPush} from "../chat/sends_push";
import {EventFacts, levelName, playerResult, Previous, TeamFacts} from "../results/player";
import {rankTeams} from "../results/ranking";
import {seasonOf, seasonPoints} from "../results/season";
import {eventIsOver, playTimeMs} from "../teams/shared";
import {Timestamp} from "firebase-admin/firestore";

// 14:00 in Romania.
const T0 = new Date("2026-11-14T12:00:00Z");
const after = (minutes: number) => new Date(T0.getTime() + minutes * 60000);

const EVENT: EventFacts = {name: "Harta", date: T0, missionCount: 3};
const FRESH: Previous = {xp: 0, stats: {games: 0, distanceMeters: 0, missions: 0, podiums: 0}, badges: []};

function team(extra: Partial<TeamFacts> = {}): TeamFacts {
  return {
    name: "Vulpile",
    userIds: ["u1"],
    numberOfMembers: 4,
    missionProgress: 3,
    startedAt: T0,
    finishedAt: after(60),
    missionTimes: new Map([[0, after(20)], [1, after(40)], [2, after(60)]]),
    hintsUsed: 1,
    walkedMeters: 1000,
    approvedPhotos: [],
    ...extra,
  };
}

const unfinished = (extra: Partial<TeamFacts> = {}) =>
  team({missionProgress: 1, finishedAt: null, missionTimes: new Map([[0, after(20)]]), ...extra});

describe("sendsPush", () => {
  test("an announcement does not, anything else does", () => {
    assert.equal(sendsPush({announcement: true}), false);
    assert.equal(sendsPush({}), true);
    assert.equal(sendsPush({announcement: false}), true);
    // Copied over when a team is renamed: already sent once.
    assert.equal(sendsPush({moved: true}), false);
  });
});

describe("seasonPoints", () => {
  test("the roadmap's table", () => {
    assert.deepEqual([1, 2, 3, 4, 5, 6].map(seasonPoints), [100, 75, 60, 50, 45, 40]);
  });

  test("never under 10", () => {
    assert.equal(seasonPoints(12), 10);
    assert.equal(seasonPoints(13), 10);
    assert.equal(seasonPoints(100), 10);
  });
});

describe("seasonOf", () => {
  const cases: [string, string, string][] = [
    ["2026-03-15T12:00:00Z", "2026-spring", "Primăvara 2026"],
    ["2026-05-31T12:00:00Z", "2026-spring", "Primăvara 2026"],
    ["2026-06-01T12:00:00Z", "2026-summer", "Vara 2026"],
    ["2026-09-01T12:00:00Z", "2026-autumn", "Toamna 2026"],
    ["2026-11-14T12:00:00Z", "2026-autumn", "Toamna 2026"],
    ["2026-12-01T12:00:00Z", "2026-winter", "Iarna 2026"],
    ["2027-01-15T12:00:00Z", "2026-winter", "Iarna 2026"],
    ["2027-02-28T12:00:00Z", "2026-winter", "Iarna 2026"],
  ];
  for (const [date, id, name] of cases) {
    test(`${date} is ${name}`, () => {
      const season = seasonOf(new Date(date));
      assert.equal(season.id, id);
      assert.equal(season.name, name);
    });
  }

  test("the boundary is Romanian midnight, not UTC", () => {
    // 1 December 00:30 in Bucharest is still 30 November in UTC.
    assert.equal(seasonOf(new Date("2026-11-30T22:30:00Z")).id, "2026-winter");
  });

  test("a season has its months", () => {
    const season = seasonOf(new Date("2026-11-14T12:00:00Z"));
    assert.equal(season.startsAt.toISOString().slice(0, 10), "2026-09-01");
    assert.equal(season.endsAt.toISOString().slice(0, 10), "2026-11-30");
  });
});

describe("levelName", () => {
  test("the steps of home_texts.dart", () => {
    assert.deepEqual(
      [0, 499, 500, 999, 1000, 2499, 2500].map(levelName),
      ["Începător", "Începător", "Explorator", "Explorator", "Cartograf", "Cartograf", "Legendă"],
    );
  });
});

describe("rankTeams", () => {
  const names = (teams: TeamFacts[]) => rankTeams(teams, 3).map((t) => t.name);

  test("finished first, the earlier finish ahead", () => {
    assert.deepEqual(names([
      unfinished({name: "A"}),
      team({name: "B", finishedAt: after(90)}),
      team({name: "C", finishedAt: after(60)}),
    ]), ["C", "B", "A"]);
  });

  test("then more missions, then the earlier last mission, then the name", () => {
    assert.deepEqual(names([
      team({name: "Zero", missionProgress: 0, finishedAt: null, missionTimes: new Map()}),
      unfinished({name: "Late", missionTimes: new Map([[0, after(30)]])}),
      unfinished({name: "Early", missionTimes: new Map([[0, after(10)]])}),
      team({name: "Two", missionProgress: 2, finishedAt: null, missionTimes: new Map([[1, after(50)]])}),
      team({name: "Alpha", missionProgress: 0, finishedAt: null, missionTimes: new Map()}),
    ]), ["Two", "Early", "Late", "Alpha", "Zero"]);
  });

  test("a finish time that was never written falls back to the last mission", () => {
    assert.deepEqual(names([
      team({name: "A", finishedAt: after(90)}),
      team({name: "B", finishedAt: null, missionTimes: new Map([[2, after(50)]])}),
    ]), ["B", "A"]);
  });

  test("it does not change what it is given", () => {
    const given = [unfinished({name: "A"}), team({name: "B"})];
    rankTeams(given, 3);
    assert.deepEqual(given.map((t) => t.name), ["A", "B"]);
  });

  test("no missions: nobody counts as finished", () => {
    assert.deepEqual(rankTeams([team({name: "B", missionProgress: 0}), team({name: "A", missionProgress: 0})], 0).map((t) => t.name), ["A", "B"]);
  });
});

describe("playerResult", () => {
  describe("xp", () => {
    test("a finished game with hints: 100 + 20 per mission, plus its badges", () => {
      const result = playerResult(team(), 5, EVENT, FRESH);
      assert.deepEqual(result.badges, ["firstGame"]);
      assert.equal(result.xp, 100 + 60 + 50);
    });

    test("no hints adds 50, and its badge 50", () => {
      const result = playerResult(team({hintsUsed: 0}), 5, EVENT, FRESH);
      assert.deepEqual(result.badges, ["firstGame", "noHints"]);
      assert.equal(result.xp, 100 + 60 + 50 + 100);
    });

    test("stopped early: only the missions", () => {
      const result = playerResult(unfinished({hintsUsed: 0}), 5, EVENT, FRESH);
      assert.deepEqual(result.badges, []);
      assert.equal(result.xp, 20);
    });

    test("it adds to what they had, and sets the level", () => {
      const result = playerResult(team(), 5, EVENT, {...FRESH, xp: 400, badges: ["firstGame"]});
      assert.equal(result.xp, 400 + 160);
      assert.equal(result.level, "Explorator");
    });

    test("progress past the end counts the real missions", () => {
      const result = playerResult(team({missionProgress: 9}), 5, EVENT, {...FRESH, badges: ["firstGame"]});
      assert.equal(result.stats.missions, 3);
      assert.equal(result.xp, 160);
    });
  });

  describe("stats", () => {
    test("added to the old ones", () => {
      const previous = {...FRESH, stats: {games: 2, distanceMeters: 500, missions: 4, podiums: 1}};
      assert.deepEqual(playerResult(team(), 3, EVENT, previous).stats, {games: 3, distanceMeters: 1500, missions: 7, podiums: 2});
    });

    test("place 4 is no podium", () => {
      assert.equal(playerResult(team(), 4, EVENT, FRESH).stats.podiums, 0);
    });
  });

  describe("badges", () => {
    const earns = (id: string, facts: Partial<TeamFacts>, place = 5, previous: Previous = FRESH) =>
      playerResult(team(facts), place, EVENT, previous).badges.includes(id);

    test("firstGame needs a finish", () => {
      assert.equal(earns("firstGame", {}), true);
      assert.equal(playerResult(unfinished(), 5, EVENT, FRESH).badges.includes("firstGame"), false);
    });

    test("games5 on the fifth", () => {
      const four = {...FRESH, stats: {...FRESH.stats, games: 4}};
      const three = {...FRESH, stats: {...FRESH.stats, games: 3}};
      assert.equal(earns("games5", {}, 5, four), true);
      assert.equal(earns("games5", {}, 5, three), false);
    });

    test("km10 and km50 count the total", () => {
      const nine = {...FRESH, stats: {...FRESH.stats, distanceMeters: 9000}};
      assert.equal(earns("km10", {walkedMeters: 999}, 5, nine), false);
      assert.equal(earns("km10", {walkedMeters: 1000}, 5, nine), true);
      const fortyNine = {...FRESH, stats: {...FRESH.stats, distanceMeters: 49000}};
      assert.equal(earns("km50", {walkedMeters: 1000}, 5, fortyNine), true);
      assert.equal(earns("km50", {walkedMeters: 999}, 5, fortyNine), false);
    });

    test("noHints needs a finish and no hint", () => {
      assert.equal(earns("noHints", {hintsUsed: 0}), true);
      assert.equal(earns("noHints", {hintsUsed: 1}), false);
    });

    test("night: the last action after 20:00 in Romania", () => {
      // 18:00 UTC is 20:00 in Bucharest in winter.
      assert.equal(earns("night", {finishedAt: new Date("2026-11-14T18:00:00Z")}), true);
      assert.equal(earns("night", {finishedAt: new Date("2026-11-14T17:59:00Z")}), false);
    });

    test("winner: first and finished", () => {
      assert.equal(earns("winner", {}, 1), true);
      assert.equal(earns("winner", {}, 2), false);
      assert.equal(playerResult(unfinished(), 1, EVENT, FRESH).badges.includes("winner"), false);
    });

    test("podium3 on the third", () => {
      const two = {...FRESH, stats: {...FRESH.stats, podiums: 2}};
      assert.equal(earns("podium3", {}, 3, two), true);
      assert.equal(earns("podium3", {}, 4, two), false);
    });

    test("photo: any approved one", () => {
      assert.equal(earns("photo", {approvedPhotos: ["a"]}), true);
      assert.equal(earns("photo", {approvedPhotos: []}), false);
    });

    test("fast: under five minutes after the one before, or the start", () => {
      assert.equal(earns("fast", {}), false);
      assert.equal(earns("fast", {missionTimes: new Map([[0, after(4)]])}), true);
      assert.equal(earns("fast", {missionTimes: new Map([[0, after(20)], [1, after(24)]])}), true);
      assert.equal(earns("fast", {missionTimes: new Map([[0, after(5)], [1, after(10)]])}), false);
    });

    test("missions50 counts the total", () => {
      const fortyEight = {...FRESH, stats: {...FRESH.stats, missions: 47}};
      assert.equal(earns("missions50", {}, 5, fortyEight), true);
      const fewer = {...FRESH, stats: {...FRESH.stats, missions: 46}};
      assert.equal(earns("missions50", {}, 5, fewer), false);
    });

    test("crew: every place taken", () => {
      assert.equal(earns("crew", {userIds: ["a", "b"], numberOfMembers: 2}), true);
      assert.equal(earns("crew", {userIds: ["a"], numberOfMembers: 2}), false);
      assert.equal(earns("crew", {userIds: ["a"], numberOfMembers: 0}), false);
    });

    test("never twice, and no XP the second time", () => {
      const result = playerResult(team(), 5, EVENT, {...FRESH, badges: ["firstGame"]});
      assert.deepEqual(result.badges, ["firstGame"]);
      assert.equal(result.xp, 160);
    });

    test("every id is in the app's catalogue", () => {
      const catalogue = ["km10", "noHints", "night", "winner", "firstGame", "games5", "km50", "podium3", "photo", "fast", "missions50", "crew"];
      const everything = {xp: 0, badges: [], stats: {games: 9, distanceMeters: 99999, missions: 99, podiums: 9}};
      const result = playerResult(team({
        hintsUsed: 0,
        approvedPhotos: ["a"],
        userIds: ["a"],
        numberOfMembers: 1,
        finishedAt: new Date("2026-11-14T19:00:00Z"),
        missionTimes: new Map([[0, after(1)]]),
      }), 1, EVENT, everything);
      assert.deepEqual([...result.badges].sort(), [...catalogue].sort());
    });
  });

  describe("memory", () => {
    test("what Profil reads", () => {
      const {memory} = playerResult(team({approvedPhotos: ["a", null, "b"]}), 2, EVENT, FRESH);
      assert.deepEqual(memory, {eventName: "Harta", date: T0, place: 2, totalTime: 60, photoUrls: ["a", "b"]});
    });

    test("stopped early: up to the last mission", () => {
      assert.equal(playerResult(unfinished(), 2, EVENT, FRESH).memory.totalTime, 20);
    });

    test("nothing solved: no time", () => {
      const none = team({missionProgress: 0, finishedAt: null, missionTimes: new Map()});
      const result = playerResult(none, 2, EVENT, FRESH);
      assert.equal(result.memory.totalTime, 0);
      assert.equal(result.xp, 0);
    });

    test("no more than the game's three hours; no start time uses the event's", () => {
      assert.equal(playerResult(team({finishedAt: after(500)}), 2, EVENT, FRESH).memory.totalTime, 180);
      assert.equal(playerResult(team({startedAt: null}), 2, EVENT, FRESH).memory.totalTime, 60);
    });

    test("no more than the event's own duration", () => {
      const short = {...EVENT, playMs: 90 * 60000};
      assert.equal(playerResult(team({finishedAt: after(500)}), 2, short, FRESH).memory.totalTime, 90);
    });
  });

  describe("the game's length", () => {
    test("the event's duration in minutes, else three hours", () => {
      assert.equal(playTimeMs({durationMinutes: 90}), 90 * 60000);
      assert.equal(playTimeMs({}), 3 * 60 * 60000);
      assert.equal(playTimeMs({durationMinutes: 0}), 3 * 60 * 60000);
      assert.equal(playTimeMs({durationMinutes: "90"}), 3 * 60 * 60000);
    });

    test("over once its duration has passed, or when stopped", () => {
      const event = {dateEvent: Timestamp.fromDate(T0), durationMinutes: 90};
      assert.equal(eventIsOver(event, after(90)), false);
      assert.equal(eventIsOver(event, after(91)), true);
      assert.equal(eventIsOver({dateEvent: Timestamp.fromDate(T0)}, after(91)), false);
      assert.equal(eventIsOver({...event, isStopped: true}, after(1)), true);
    });
  });

  test("an event with no missions breaks nothing", () => {
    const result = playerResult(team({missionProgress: 0, finishedAt: null, missionTimes: new Map()}), 1, {...EVENT, missionCount: 0}, FRESH);
    assert.equal(result.xp, 0);
    assert.equal(result.stats.games, 1);
  });
});
