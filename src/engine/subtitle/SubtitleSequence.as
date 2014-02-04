package engine.subtitle
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class SubtitleSequence extends EventDispatcher
	{
		public static const EVENT_CURRENT : String = "SubtitleSequence.EVENT_CURRENT";

		public var timer : Timer = new Timer(0, 1);

		public var subtitles : Vector.<Subtitle> = new Vector.<Subtitle>;
		public var index : int = -1;

		public var elapsed : int = 0;
		public var startTime : int = 0;
		private var _current : Subtitle;

		public var url : String;

		public function get current() : Subtitle
		{
			return _current;
		}

		public function set current(value : Subtitle) : void
		{
			if (_current == value)
			{
				return;
			}

			_current = value;
			dispatchEvent(new Event(EVENT_CURRENT));
		}

		public function stop() : void
		{
			timer.reset();
			current = null;
			index = 0;
			startTime = 0;
		}

		public function SubtitleSequence()
		{
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
		}

		public function startSubtitles() : void
		{
			timer.reset();
			index = -1;
			elapsed = 0;
			startTime = getTimer();
			queueNext();
		}

		public function queueNext() : void
		{
			var pn : Subtitle = peekNext;
			if (pn)
			{
				timer.reset();
				timer.delay = Math.max(0, pn.start - elapsed);
				timer.repeatCount = 1;
				timer.start();
			}
		}

		public function get peekNext() : Subtitle
		{
			var ni : int = index + 1;
			if (ni >= subtitles.length)
			{
				return null;
			}

			return subtitles[ni];
		}

		public function next() : void
		{
			var ni : int = index + 1;
			if (ni >= subtitles.length)
			{
				return;
			}

			index = ni;
			current = subtitles[index];

			var nt : int = current.end;

			var pn : Subtitle = peekNext;
			if (pn)
			{
				nt = Math.min(pn.start, nt);
			}

			timer.reset();
			timer.delay = Math.max(0, nt - elapsed);
			timer.repeatCount = 1;
			timer.start();
		}

		private function timerHandler(event : TimerEvent) : void
		{
			elapsed = getTimer() - startTime;

			if (current)
			{
				current = null;
			}

			var pn : Subtitle = peekNext;
			if (pn)
			{
				if (pn.start <= elapsed)
				{
					next();
				}
				else
				{
					queueNext();
				}
			}
		}

		//////

		public function fromJson(json : Object) : SubtitleSequence
		{

			for each (var sj : Object in json.subtitles)
			{
				var s : Subtitle = new Subtitle().fromJson(sj);
				subtitles.push(s);
			}
			return this;
		}

		public function toJson() : Object
		{
			var r : Object =
				{
					subtitles: []
				};

			for each (var s : Subtitle in subtitles)
			{
				var sj : Object = s.toJson();
				r.subtitles.push(sj);
			}

			return r;
		}

		///

		public function fromSbv(s : String) : SubtitleSequence
		{
			s = s.replace(/\r/gi, "");
			var lines : Array = s.split("\n");

			var cs : Subtitle;
			for (var linenum : int = 0; linenum < lines.length; ++linenum)
			{
				var line : String = lines[linenum];
				if (!line)
				{
					if (cs)
					{
						cs = null;
					}
					continue;
				}

				if (!cs)
				{
					// this should be the timestamp

					cs = new Subtitle();
					subtitles.push(cs);

					var tsv : Array = line.split(",");

					if (tsv.length != 2)
					{
						throw new ArgumentError("Line [" + linenum + "] expected timestamp range, found [" + line + "]");
					}

					try
					{
						cs.start = parseTimestamp(tsv[0]);
						cs.end = parseTimestamp(tsv[1]);
					}
					catch (e : Error)
					{
						throw new ArgumentError("Line [" + linenum + "] error: " + e.message);
					}
				}
				else
				{
					if (cs.text)
					{
						cs.text += "\n" + line;
					}
					else
					{
						cs.text = line;
					}
				}
			}

			return this;
		}

		public function toSbv() : String
		{
			var s : String = "";

			for each (var sub : Subtitle in subtitles)
			{
				s += formatTimestamp(sub.start);
				s += ",";
				s += formatTimestamp(sub.start);
				s += "\n";
				s += sub.text;

				var last : String = sub.text ? sub.text.charAt(sub.text.length - 1) : null;
				if (last != "\n")
				{
					s += "\n";
				}

				s += "\n";
			}

			return s;
		}

		public static function parseTimestamp(s : String) : int
		{
			if (!s)
			{
				return 0;
			}
			var parts : Array = s.split(":");

			if (parts.length != 3)
			{
				throw new ArgumentError("Invalid timestamp [" + s + "]");
			}

			var secpart : String = parts[2];
			var minpart : String = parts[1];
			var hourpart : String = parts[0];

			var dot : int = secpart.indexOf(".");

			var ms : int = 0;

			if (dot > 0)
			{
				parts[2] = secpart.substr(0, dot);
				var mspart : String = secpart.substr(dot + 1);
				secpart = parts[2];
				ms += int(mspart);
			}

			ms += int(secpart) * 1000;
			ms += int(minpart) * 1000 * 60;
			ms += int(hourpart) * 1000 * 60 * 60;

			return ms;
		}

		public static function pl(v : int, n : int = 2) : String
		{
			return padLeft(v.toString(), "0", n);
		}

		public static function padLeft(str : String, p : String, w : int) : String
		{
			if (!p)
			{
				throw new ArgumentError("Bad pad");
			}

			if (str.length >= w)
			{
				return str;
			}

			var r : String = str;

			var a : int = (w - r.length) / p.length;
			for (var i : int = 0; i < a; ++i)
			{
				r = p + r;
			}

			return r;
		}

		public static function formatTimestamp(t : Number) : String
		{
			var result : String = "";

			var s : int = (t / 1000);
			var m : int = s / 60;
			var h : int = m / 60;

			m -= h * 60;
			s -= m * 60;
			var ms : int = t - (s * 1000);

			return pl(h) +
				":" +
				pl(m) +
				":" +
				pl(s) +
				"." +
				pl(ms, 3);

		}
	}
}
