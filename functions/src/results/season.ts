import {bucharestTime} from "../teams/shared";

/** 100, 75, 60, then 50 minus 5 for each place below, never less than 10. */
export function seasonPoints(place: number): number {
  if (place === 1) return 100;
  if (place === 2) return 75;
  if (place === 3) return 60;
  return Math.max(10, 50 - 5 * (place - 4));
}

export interface Season {
  id: string;
  name: string;
  startsAt: Date;
  endsAt: Date;
}

/**
 * The season of a date, in Romania's calendar: Primăvara March to May, Vara June
 * to August, Toamna September to November, Iarna December to February, named
 * for the year of its December.
 */
export function seasonOf(date: Date): Season {
  const {year, month} = bucharestTime(date);
  const of = (id: string, name: string, firstMonth: number, startYear: number): Season => ({
    id: `${startYear}-${id}`,
    name: `${name} ${startYear}`,
    startsAt: new Date(Date.UTC(startYear, firstMonth - 1, 1)),
    endsAt: new Date(Date.UTC(startYear, firstMonth + 2, 1) - 1000),
  });
  if (month >= 3 && month <= 5) return of("spring", "Primăvara", 3, year);
  if (month >= 6 && month <= 8) return of("summer", "Vara", 6, year);
  if (month >= 9 && month <= 11) return of("autumn", "Toamna", 9, year);
  return of("winter", "Iarna", 12, month === 12 ? year : year - 1);
}
