# frozen_string_literal: true

# MIT License
#
# Copyright (c) 2024 Zerocracy
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'fbe/conclude'

Fbe.conclude do
  on "(and
    (eq what 'bug-was-resolved')
    (exists where)
    (exists seconds)
    (exists when)
    (gt when #{(Time.now - (J.pmp.hr.days_to_reward * 24 * 60 * 60)).utc.iso8601})
    (exists issue)
    (exists repository)
    (exists who)
    (eq is_human 1)
    (empty (and
      (eq what '#{$judge}')
      (eq where $where)
      (eq issue $issue)
      (eq repository $repository))))"
  follow 'where repository issue who'
  draw do |n, resolved|
    hours = resolved.seconds / (60 * 60)
    a = J.award(
      {
        kind: :const,
        points: 30,
        because: 'as a basis'
      },
      {
        if: hours < 24,
        kind: :const,
        points: +10,
        because: 'for resolving it in less than 24 hours'
      },
      {
        kind: :linear,
        x: hours / 24,
        k: -1,
        because: "for #{hours / 24} days of delay",
        min: -20,
        at_least: -5
      }
    )
    n.award = a[:points]
    n.when = Time.now
    n.why = "Bug #{J.issue(n)} was resolved"
    n.greeting = [
      'Thanks for closing this issue! ',
      a[:greeting],
      J.balance(n.who)
    ].join
    "It's time to reward #{J.who(n)} for the bug resolved in " \
      "#{J.issue(n)}, the reward amount is #{n.award}."
  end
end
