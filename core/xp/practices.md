# XP Practices

## Test-First Programming
Write tests before code. Tests drive the Red-Green-Refactor cycle.

## Small Releases
Deliver value in small increments. Stories should be the smallest splittable unit.

## Whole Team
Quality and direction are the entire team's responsibility.

## Planning Game
PdM decides story priority. Architect estimates complexity/uncertainty
on a 3-level scale (1pt Clear, 2pt Challenging, 3pt Uncertain).
A story estimated at 3pt ("too large") must not proceed to implementation;
PdM splits, redefines, or commissions a spike to reduce uncertainty first.

## On-Site Customer
PdM acts as the user's advocate, always present with the team.
Defines acceptance criteria and makes completion judgments.

## Collective Code Ownership
Code belongs to no specific agent. Refactor agent improving
other agents' code is welcomed.

## Continuous Integration
Tests must always stay Green. Never proceed to the next task while Red.

## Incremental Design
No big design up front. Design only what the current story needs.
Design emerges through TDD and is refined through refactoring.
