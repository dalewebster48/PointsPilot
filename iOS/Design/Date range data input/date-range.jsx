// Date range input variations
// All share: 1-year range from today, tappable months, "open" start/end concept
// Summary copy: "Any time after X" / "Between X and Y" / "Any time before X" / "Around June" etc.

const ACCENT = window.__ACCENT__ || '#FF6B4A';
const today = new Date(2026, 3, 26); // 26 Apr 2026
const yearOut = new Date(2027, 3, 25);

// ─── shared helpers ──────────────────────────────────────────
const MONTH_SHORT = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const MONTH_LONG = ['January','February','March','April','May','June','July','August','September','October','November','December'];

function fmtDate(d) {
  if (!d) return '';
  return `${d.getDate()} ${MONTH_SHORT[d.getMonth()]} ${d.getFullYear()}`;
}
function fmtDay(d) {
  return `${MONTH_SHORT[d.getMonth()]} ${d.getDate()}`;
}
function daysBetween(a, b) {
  return Math.round((b - a) / 86400000);
}
function addDays(d, n) {
  const x = new Date(d);
  x.setDate(x.getDate() + n);
  return x;
}

// build the 12 months we can pick from (today's month → +11)
function rollingMonths() {
  const out = [];
  for (let i = 0; i < 12; i++) {
    const d = new Date(today.getFullYear(), today.getMonth() + i, 1);
    out.push({
      idx: i,
      label: MONTH_SHORT[d.getMonth()],
      long: MONTH_LONG[d.getMonth()],
      year: d.getFullYear(),
      monthNum: d.getMonth(),
      // first/last selectable day in this month, clamped to [today, today+1y]
      first: i === 0 ? today : new Date(d.getFullYear(), d.getMonth(), 1),
      last: (() => {
        const endMonth = new Date(d.getFullYear(), d.getMonth() + 1, 0);
        return i === 11 ? (endMonth < yearOut ? endMonth : yearOut) : endMonth;
      })(),
    });
  }
  return out;
}
const MONTHS = rollingMonths();

// summary: takes { start, end } where either can be null = "open"
// returns string for the summary box
function summarize({ start, end, label }) {
  if (label) return label; // explicit override (e.g. "Around June")
  if (!start && !end) return 'Any time in the next year';
  if (start && !end) return `Any time after ${fmtDay(start)}`;
  if (!start && end) return `Any time before ${fmtDay(end)}`;
  if (sameDay(start, end)) return `On ${fmtDay(start)}`;
  return `Between ${fmtDay(start)} and ${fmtDay(end)}`;
}
function sameDay(a, b) {
  return a && b && a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

// ─── shared chrome: header + summary card ────────────────────
function ScreenChrome({ children, summary, onOk }) {
  return (
    <div style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      background: '#fff', position: 'relative',
    }}>
      {/* top bar */}
      <div style={{
        paddingTop: 54, paddingLeft: 16, paddingRight: 16, paddingBottom: 8,
        display: 'flex', alignItems: 'center', position: 'relative', flexShrink: 0,
      }}>
        <button style={{
          width: 36, height: 36, borderRadius: 18, border: 'none',
          background: '#F2F2F2', display: 'grid', placeItems: 'center', cursor: 'pointer',
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
            <path d="M15 6l-6 6 6 6" stroke="#111" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
        <div style={{
          position: 'absolute', left: 0, right: 0, textAlign: 'center',
          fontSize: 17, fontWeight: 600, color: '#111', pointerEvents: 'none',
        }}>When?</div>
      </div>

      {/* body */}
      <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
        {children}
      </div>

      {/* summary card */}
      <SummaryCard summary={summary} onOk={onOk} />
    </div>
  );
}

function SummaryCard({ summary, onOk }) {
  return (
    <div style={{
      margin: '0 16px 28px', borderRadius: 24, background: '#FAFAFA',
      boxShadow: '0 8px 32px rgba(0,0,0,0.08), 0 2px 6px rgba(0,0,0,0.04), inset 0 0 0 1px rgba(0,0,0,0.04)',
      padding: '20px 20px 16px', flexShrink: 0,
    }}>
      <div style={{ fontSize: 24, fontWeight: 700, letterSpacing: -0.4, color: '#111' }}>When are you travelling?</div>
      <div style={{ fontSize: 13, color: '#666', marginTop: 2 }}>Pick when you're free</div>
      <div style={{ height: 1, background: 'rgba(0,0,0,0.08)', margin: '14px 0' }} />
      <div style={{
        minHeight: 56, display: 'grid', placeItems: 'center', textAlign: 'center',
        padding: '4px 8px',
      }}>
        <div key={summary} style={{
          fontSize: 17, fontWeight: 500, color: '#111', letterSpacing: -0.2,
          animation: 'summFade 240ms cubic-bezier(.34,1.56,.64,1)',
        }}>
          {summary}
        </div>
      </div>
      <div style={{ height: 1, background: 'rgba(0,0,0,0.08)', margin: '12px 0 14px' }} />
      <button onClick={onOk} style={{
        width: '100%', height: 50, borderRadius: 16, border: 'none',
        background: ACCENT, color: '#fff', fontSize: 17, fontWeight: 600,
        cursor: 'pointer', letterSpacing: -0.2,
      }}>Ok</button>
    </div>
  );
}

// ═════════════════════════════════════════════════════════════
// VARIATION A — Paint the months
// Tap any month to toggle, drag-paint across multiple. Selected
// = a contiguous run that becomes the date range. Explicitness
// inferred: tap one month = "Around June", paint several = "Between X and Y".
// ═════════════════════════════════════════════════════════════
function PaintMonths() {
  const [sel, setSel] = React.useState(new Set([3, 4])); // first 2 months by default
  const [painting, setPainting] = React.useState(null); // 'add' | 'remove' | null

  const toggle = (i, mode) => {
    setSel(prev => {
      const next = new Set(prev);
      if (mode === 'add') next.add(i);
      else if (mode === 'remove') next.delete(i);
      else next.has(i) ? next.delete(i) : next.add(i);
      return next;
    });
  };

  const clear = () => setSel(new Set());

  // build summary from contiguous selected months
  const summary = React.useMemo(() => {
    if (sel.size === 0) return 'Pick one or more months';
    const sorted = [...sel].sort((a,b)=>a-b);
    if (sorted.length === 1) {
      const m = MONTHS[sorted[0]];
      return `Around ${m.long}`;
    }
    // find runs
    const runs = [];
    let run = [sorted[0]];
    for (let i = 1; i < sorted.length; i++) {
      if (sorted[i] === sorted[i-1] + 1) run.push(sorted[i]);
      else { runs.push(run); run = [sorted[i]]; }
    }
    runs.push(run);
    if (runs.length === 1) {
      const first = MONTHS[runs[0][0]];
      const last = MONTHS[runs[0][runs[0].length - 1]];
      return `Between ${first.long} and ${last.long}`;
    }
    return `${sorted.map(i => MONTHS[i].label).join(', ')}`;
  }, [sel]);

  return (
    <ScreenChrome summary={summary} onOk={() => {}}>
      <div style={{ padding: '16px 20px 20px', flex: 1 }}
        onPointerUp={() => setPainting(null)}
        onPointerLeave={() => setPainting(null)}>
        <div style={{ fontSize: 13, color: '#888', marginBottom: 14, letterSpacing: -0.1 }}>
          Tap or drag across the months you can travel
        </div>
        <div style={{
          display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10,
        }}>
          {MONTHS.map((m, i) => {
            const isSel = sel.has(i);
            return (
              <button key={i}
                onPointerDown={(e) => {
                  e.preventDefault();
                  const mode = isSel ? 'remove' : 'add';
                  setPainting(mode);
                  toggle(i, mode);
                }}
                onPointerEnter={() => { if (painting) toggle(i, painting); }}
                style={{
                  height: 64, borderRadius: 18, border: 'none', cursor: 'pointer',
                  background: isSel ? ACCENT : '#F4F4F5',
                  color: isSel ? '#fff' : '#111',
                  fontSize: 15, fontWeight: 600, letterSpacing: -0.2,
                  display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                  gap: 2, transition: 'transform 160ms cubic-bezier(.34,1.56,.64,1), background 160ms ease',
                  transform: isSel ? 'scale(1.02)' : 'scale(1)',
                  touchAction: 'none', userSelect: 'none',
                }}>
                <div>{m.label}</div>
                <div style={{ fontSize: 10, opacity: 0.55, fontWeight: 500 }}>{m.year}</div>
              </button>
            );
          })}
        </div>
        <button onClick={clear} style={{
          marginTop: 18, background: 'transparent', border: 'none',
          color: '#888', fontSize: 13, cursor: 'pointer', padding: 4,
        }}>Clear</button>
      </div>
    </ScreenChrome>
  );
}

// ═════════════════════════════════════════════════════════════
// VARIATION B — Year ribbon with two open-ended handles
// A horizontal year strip. Tap once = an "anytime after" anchor.
// Tap twice = a range. The two handles can each be "open" (sit at
// the edge) — if a handle is at edge, it reads as "Any time before/after".
// ═════════════════════════════════════════════════════════════
function YearRibbon() {
  // values are days from today (0..365). null = "open" (no constraint)
  const [a, setA] = React.useState(0);   // start
  const [b, setB] = React.useState(60);  // end
  const [drag, setDrag] = React.useState(null); // 'a' | 'b' | null
  const ribbonRef = React.useRef(null);

  const TOTAL = 365;

  const startDate = a === null ? null : addDays(today, a);
  const endDate = b === null ? null : addDays(today, b);

  // smart summary: if a==0 (at min edge) treat as open-start; if b==TOTAL treat as open-end
  const openStart = a === 0;
  const openEnd = b === TOTAL;
  const summary = React.useMemo(() => {
    if (openStart && openEnd) return 'Any time in the next year';
    if (openStart && !openEnd) return `Any time before ${fmtDay(endDate)}`;
    if (!openStart && openEnd) return `Any time after ${fmtDay(startDate)}`;
    if (sameDay(startDate, endDate)) return `On ${fmtDay(startDate)}`;
    return `Between ${fmtDay(startDate)} and ${fmtDay(endDate)}`;
  }, [a, b, openStart, openEnd]);

  const onMove = (clientX) => {
    if (!ribbonRef.current || !drag) return;
    const rect = ribbonRef.current.getBoundingClientRect();
    const pct = Math.max(0, Math.min(1, (clientX - rect.left) / rect.width));
    const day = Math.round(pct * TOTAL);
    if (drag === 'a') setA(Math.min(day, b - 1));
    else setB(Math.max(day, a + 1));
  };

  React.useEffect(() => {
    if (!drag) return;
    const move = (e) => onMove(e.clientX ?? e.touches?.[0]?.clientX);
    const up = () => setDrag(null);
    window.addEventListener('pointermove', move);
    window.addEventListener('pointerup', up);
    return () => {
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', up);
    };
  }, [drag, a, b]);

  // month tick positions
  const ticks = MONTHS.map((m, i) => {
    const dayIntoYear = daysBetween(today, m.first);
    return { ...m, pct: Math.max(0, dayIntoYear / TOTAL) };
  });

  return (
    <ScreenChrome summary={summary} onOk={() => {}}>
      <div style={{ padding: '16px 20px 20px', flex: 1 }}>
        <div style={{ fontSize: 13, color: '#888', marginBottom: 22, letterSpacing: -0.1 }}>
          Drag the handles to set your window
        </div>

        {/* Big floating dates */}
        <div style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'baseline',
          marginBottom: 18, padding: '0 4px',
        }}>
          <div>
            <div style={{ fontSize: 11, color: '#888', textTransform: 'uppercase', letterSpacing: 0.6, fontWeight: 600 }}>From</div>
            <div style={{ fontSize: 22, fontWeight: 700, color: '#111', letterSpacing: -0.5, marginTop: 2 }}>
              {openStart ? 'Anytime' : fmtDay(startDate)}
            </div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: 11, color: '#888', textTransform: 'uppercase', letterSpacing: 0.6, fontWeight: 600 }}>To</div>
            <div style={{ fontSize: 22, fontWeight: 700, color: '#111', letterSpacing: -0.5, marginTop: 2 }}>
              {openEnd ? 'Anytime' : fmtDay(endDate)}
            </div>
          </div>
        </div>

        {/* Ribbon */}
        <div ref={ribbonRef} style={{
          position: 'relative', height: 88, marginTop: 8,
          touchAction: 'none', userSelect: 'none',
        }}>
          {/* track */}
          <div style={{
            position: 'absolute', top: 38, left: 0, right: 0, height: 12,
            borderRadius: 6, background: '#F0F0F2',
          }} />
          {/* selected fill */}
          <div style={{
            position: 'absolute', top: 38, height: 12, borderRadius: 6,
            background: ACCENT,
            left: `${(a / TOTAL) * 100}%`,
            right: `${(1 - b / TOTAL) * 100}%`,
            transition: drag ? 'none' : 'all 220ms cubic-bezier(.34,1.56,.64,1)',
          }} />

          {/* month ticks */}
          {ticks.map((t, i) => (
            <div key={i} style={{
              position: 'absolute', top: 58, left: `${t.pct * 100}%`,
              transform: 'translateX(-50%)',
              fontSize: 9, color: '#aaa', fontWeight: 600, letterSpacing: 0.3,
              pointerEvents: 'none',
            }}>{t.label[0]}</div>
          ))}

          {/* handle A */}
          <Handle pos={a / TOTAL} onDown={() => setDrag('a')} dragging={drag === 'a'} />
          {/* handle B */}
          <Handle pos={b / TOTAL} onDown={() => setDrag('b')} dragging={drag === 'b'} />
        </div>

        {/* Quick chips */}
        <div style={{ marginTop: 28 }}>
          <div style={{ fontSize: 11, color: '#888', textTransform: 'uppercase', letterSpacing: 0.6, fontWeight: 600, marginBottom: 10 }}>
            Quick picks
          </div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {[
              { label: 'This weekend', a: 4, b: 6 },
              { label: 'Next month', a: 30, b: 60 },
              { label: 'Summer', a: 60, b: 150 },
              { label: 'Anytime', a: 0, b: 365 },
            ].map(p => (
              <button key={p.label}
                onClick={() => { setA(p.a); setB(p.b); }}
                style={{
                  padding: '8px 14px', borderRadius: 999, border: 'none',
                  background: '#F4F4F5', color: '#333', fontSize: 13, fontWeight: 500,
                  cursor: 'pointer', letterSpacing: -0.1,
                }}>{p.label}</button>
            ))}
          </div>
        </div>
      </div>
    </ScreenChrome>
  );
}

function Handle({ pos, onDown, dragging }) {
  return (
    <div onPointerDown={(e) => { e.preventDefault(); onDown(); }}
      style={{
        position: 'absolute', top: 30, left: `${pos * 100}%`,
        width: 28, height: 28, transform: 'translate(-50%, 0)',
        borderRadius: 14, background: '#fff', cursor: 'grab',
        boxShadow: dragging
          ? `0 0 0 6px ${ACCENT}33, 0 4px 12px rgba(0,0,0,0.12)`
          : '0 0 0 2px ' + ACCENT + ', 0 2px 6px rgba(0,0,0,0.1)',
        transition: dragging ? 'box-shadow 160ms' : 'box-shadow 160ms, transform 220ms cubic-bezier(.34,1.56,.64,1)',
        touchAction: 'none', zIndex: 5,
      }} />
  );
}

// ═════════════════════════════════════════════════════════════
// VARIATION C — Mini year calendar (12 months × tappable days)
// The "all in one" approach: see the whole year at once. Tap a
// day to set start, tap another to set end. Tap a month header
// to select the whole month. Long-press an end to "open" it.
// ═════════════════════════════════════════════════════════════
function MiniYearCalendar() {
  // store start/end as Date or null (open)
  const [range, setRange] = React.useState({
    start: addDays(today, 14),
    end: addDays(today, 35),
  });

  const handleDayTap = (d) => {
    setRange(prev => {
      const { start, end } = prev;
      // no anchor → set start, clear end
      if (!start || (start && end)) return { start: d, end: null };
      // we have start, no end → set end (or swap)
      if (d < start) return { start: d, end: start };
      if (sameDay(d, start)) return { start: d, end: d };
      return { start, end: d };
    });
  };

  const handleMonthTap = (m) => {
    setRange({ start: m.first, end: m.last });
  };

  const summary = summarize({ start: range.start, end: range.end });

  return (
    <ScreenChrome summary={summary} onOk={() => {}}>
      <div style={{ padding: '12px 16px 16px', flex: 1, overflowY: 'auto' }}>
        <div style={{ fontSize: 13, color: '#888', marginBottom: 12, padding: '0 4px', letterSpacing: -0.1 }}>
          Tap a month, or pick exact dates
        </div>
        <div style={{
          display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14,
        }}>
          {MONTHS.map((m, i) => (
            <MiniMonth key={i} m={m} range={range}
              onMonthTap={() => handleMonthTap(m)}
              onDayTap={handleDayTap} />
          ))}
        </div>
      </div>
    </ScreenChrome>
  );
}

function MiniMonth({ m, range, onMonthTap, onDayTap }) {
  // build 6×7 grid of dates for this month
  const firstDow = new Date(m.year, m.monthNum, 1).getDay(); // 0 sun
  const offset = (firstDow + 6) % 7; // make monday = 0
  const daysInMonth = new Date(m.year, m.monthNum + 1, 0).getDate();
  const cells = [];
  for (let i = 0; i < offset; i++) cells.push(null);
  for (let d = 1; d <= daysInMonth; d++) cells.push(new Date(m.year, m.monthNum, d));

  // is the entire month within range?
  const monthInRange = range.start && range.end &&
    range.start <= m.first && range.end >= m.last;

  return (
    <div style={{
      borderRadius: 14, padding: '8px 6px 6px',
      background: monthInRange ? ACCENT + '14' : 'transparent',
      transition: 'background 200ms',
    }}>
      <button onClick={onMonthTap} style={{
        width: '100%', textAlign: 'left', background: 'transparent', border: 'none',
        cursor: 'pointer', padding: '0 4px 4px', fontSize: 12, fontWeight: 700,
        color: monthInRange ? ACCENT : '#111', letterSpacing: -0.1,
        display: 'flex', justifyContent: 'space-between', alignItems: 'baseline',
      }}>
        <span>{m.long}</span>
        <span style={{ fontSize: 9, color: '#bbb', fontWeight: 500 }}>{m.year}</span>
      </button>
      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 1,
      }}>
        {cells.map((d, i) => {
          if (!d) return <div key={i} />;
          const tooEarly = d < today;
          const tooLate = d > yearOut;
          const disabled = tooEarly || tooLate;
          let state = 'idle';
          if (range.start && sameDay(d, range.start)) state = 'start';
          else if (range.end && sameDay(d, range.end)) state = 'end';
          else if (range.start && range.end && d > range.start && d < range.end) state = 'mid';
          else if (range.start && !range.end && sameDay(d, range.start)) state = 'start';

          return (
            <button key={i}
              disabled={disabled}
              onClick={() => !disabled && onDayTap(d)}
              style={{
                aspectRatio: '1', border: 'none', cursor: disabled ? 'default' : 'pointer',
                fontSize: 9.5, fontWeight: state === 'idle' ? 500 : 700,
                color: disabled ? '#ddd'
                     : state === 'start' || state === 'end' ? '#fff'
                     : state === 'mid' ? ACCENT
                     : '#333',
                background: state === 'start' || state === 'end' ? ACCENT
                         : state === 'mid' ? ACCENT + '22'
                         : 'transparent',
                borderRadius: state === 'start' ? '8px 4px 4px 8px'
                            : state === 'end' ? '4px 8px 8px 4px'
                            : state === 'mid' ? 4
                            : 8,
                padding: 0, transition: 'background 160ms, color 160ms',
              }}>
              {d.getDate()}
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ═════════════════════════════════════════════════════════════
// VARIATION D — Conversational "from … to …"
// Two big tappable phrases. Each opens a quick picker (an exact
// date or "anytime"). Reads like a sentence.
// ═════════════════════════════════════════════════════════════
function Conversational() {
  const [start, setStart] = React.useState(addDays(today, 0));
  const [end, setEnd] = React.useState(addDays(today, 90));
  const [open, setOpen] = React.useState(null); // 'start' | 'end' | null

  const summary = summarize({ start, end });

  return (
    <ScreenChrome summary={summary} onOk={() => {}}>
      <div style={{ padding: '24px 24px 16px', flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{
          fontSize: 28, lineHeight: 1.35, fontWeight: 600, color: '#111',
          letterSpacing: -0.6, marginTop: 8,
        }}>
          <span style={{ color: '#888', fontWeight: 500 }}>From</span>{' '}
          <Phrase active={open === 'start'} onClick={() => setOpen(open === 'start' ? null : 'start')}>
            {start ? fmtDay(start) : 'anytime'}
          </Phrase>
          {' '}<span style={{ color: '#888', fontWeight: 500 }}>to</span>{' '}
          <Phrase active={open === 'end'} onClick={() => setOpen(open === 'end' ? null : 'end')}>
            {end ? fmtDay(end) : 'anytime'}
          </Phrase>
          <span style={{ color: '#888', fontWeight: 500 }}>.</span>
        </div>

        {/* picker */}
        {open && (
          <div style={{
            marginTop: 20, borderRadius: 20, background: '#F7F7F8',
            padding: 14, animation: 'slideUp 280ms cubic-bezier(.34,1.56,.64,1)',
          }}>
            <div style={{ fontSize: 11, color: '#888', textTransform: 'uppercase', letterSpacing: 0.6, fontWeight: 600, marginBottom: 10, padding: '0 4px' }}>
              {open === 'start' ? 'From which date?' : 'Until which date?'}
            </div>
            <div style={{
              display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 6,
            }}>
              <button onClick={() => { open === 'start' ? setStart(null) : setEnd(null); setOpen(null); }}
                style={pickerChipStyle(false, true)}>Anytime</button>
              {[0, 7, 14, 30, 60, 90, 180].map(n => {
                const d = addDays(today, n);
                const active = open === 'start'
                  ? (start && sameDay(d, start))
                  : (end && sameDay(d, end));
                return (
                  <button key={n}
                    onClick={() => { open === 'start' ? setStart(d) : setEnd(d); }}
                    style={pickerChipStyle(active)}>
                    {n === 0 ? 'Today' : n === 7 ? '+1w' : n === 14 ? '+2w' : n === 30 ? '+1m' : n === 60 ? '+2m' : n === 90 ? '+3m' : '+6m'}
                  </button>
                );
              })}
            </div>
            <div style={{ marginTop: 12, padding: '0 4px' }}>
              <div style={{ fontSize: 11, color: '#888', textTransform: 'uppercase', letterSpacing: 0.6, fontWeight: 600, marginBottom: 8 }}>
                Or pick a month
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
                {MONTHS.slice(0, 6).map((m, i) => (
                  <button key={i}
                    onClick={() => {
                      open === 'start' ? setStart(m.first) : setEnd(m.last);
                    }}
                    style={pickerChipStyle(false)}>{m.label}</button>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </ScreenChrome>
  );
}

function pickerChipStyle(active, wide = false) {
  return {
    padding: wide ? '10px 14px' : '10px 8px',
    borderRadius: 12, border: 'none', cursor: 'pointer',
    background: active ? ACCENT : '#fff',
    color: active ? '#fff' : '#333',
    fontSize: 13, fontWeight: 600, letterSpacing: -0.1,
    boxShadow: active ? 'none' : 'inset 0 0 0 1px rgba(0,0,0,0.06)',
    transition: 'all 160ms',
    gridColumn: wide ? 'span 2' : 'auto',
  };
}

function Phrase({ children, active, onClick }) {
  return (
    <button onClick={onClick} style={{
      background: active ? ACCENT : '#F4F4F5',
      color: active ? '#fff' : '#111',
      border: 'none', cursor: 'pointer',
      padding: '4px 12px', borderRadius: 12,
      fontSize: 'inherit', fontWeight: 700, letterSpacing: -0.4,
      fontFamily: 'inherit',
      transition: 'all 200ms cubic-bezier(.34,1.56,.64,1)',
      transform: active ? 'scale(1.02)' : 'scale(1)',
    }}>{children}</button>
  );
}

Object.assign(window, {
  PaintMonths, YearRibbon, MiniYearCalendar, Conversational,
  ScreenChrome, SummaryCard, summarize, MONTHS, today, yearOut,
  fmtDay, sameDay, addDays,
});
