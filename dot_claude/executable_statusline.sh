#!/bin/sh
# Claude Code status line: model, effort, context window, subscription rate
# limits, and session cost on one dim line. Values turn yellow at 70% and red
# at 90%. Rate limits show their reset countdown once they pass 50%.
# One jq process per refresh; no other commands run.
exec jq -rj '
  def dim: "\u001b[2m";
  def off: "\u001b[0m\u001b[2m";
  def yellow: "\u001b[33m";
  def red: "\u001b[31m";
  def tone(p): if p >= 90 then red elif p >= 70 then yellow else "" end;
  def pct(p): (p | floor | tostring) + "%";
  def bar(p): (p / 20 | floor | if . > 5 then 5 else . end) as $n
    | ("▰" * $n) + ("▱" * (5 - $n));
  def countdown(t): ((t - now) | if . < 0 then 0 else . end) as $s
    | if $s >= 86400 then ((($s / 86400) | floor | tostring) + "d")
      elif $s >= 3600 then ((($s / 3600) | floor | tostring) + "h")
      else ((($s / 60) | floor | tostring) + "m") end;
  def window(name; w):
    if w == null or w.used_percentage == null then empty
    else (w.used_percentage) as $p
      | tone($p) + name + " " + pct($p) + off
        + (if $p >= 50 and w.resets_at != null then dim + " ↻" + countdown(w.resets_at) + off else "" end)
    end;

  [
    (.model.display_name // "Claude"),
    (.effort.level // empty),
    (.context_window.used_percentage as $p
      | if $p == null then empty
        else tone($p) + "ctx " + bar($p) + " " + pct($p) + off end),
    window("5h"; .rate_limits.five_hour),
    window("7d"; .rate_limits.seven_day),
    window("spend"; .rate_limits.spend_limit),
    (.cost.total_cost_usd as $c
      | if $c == null or $c < 0.01 then empty
        else "$" + (if $c >= 10 then ($c | floor | tostring) else (($c * 100 | round) / 100 | tostring) end) end)
  ]
  | map(select(. != null))
  | dim + join(" · ") + "\u001b[0m"
'
