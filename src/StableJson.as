package
{

	public class StableJson
	{
		public function StableJson()
		{
		}

		public static function stringify(r : *, replacer : Function, indent : String = "", curIndent : String = "") : String
		{
			if (r == null || r == undefined)
			{
				return "null";
			}

			if (r is String)
			{
				var s : String = r as String;

				// first unquote all quotes
				s = s.replace(/\\\"/g, "\"");
				// now requote them
				s = s.replace(/\"/g, "\\\"");

				// newlines
				s = s.replace(/\n/g, "\\n");
				return "\"" + s + "\"";
			}
			else if (r is Number)
			{
				if (isNaN(r))
				{
					return "0";
				}
				return r;
			}
			else if (r is uint || r is int || r is Boolean)
			{
				return r;
			}
			else if (r is Array)
			{
				return stringifyArray(r, indent, curIndent);
			}
			else if (r is Object)
			{
				return stringifyObject(r, indent, curIndent);
			}

			return "null";
		}

		public static function stringifyArray(r : Array, indent : String = "", curIndent : String = "") : String
		{
			var rs : String = "[";
			var ni : String = curIndent + indent;
			var avf : Boolean;
			for each (var av : * in r)
			{
				if (avf)
				{
					rs += ",\n";
				}
				else
				{
					rs += "\n";
				}

				rs += ni + stringify(av, null, indent, ni);
				avf = true;
			}

			if (avf)
			{
				rs += "\n" + curIndent + "]";
			}
			else
			{
				rs += "]";
			}
			return rs;
		}

		public static function stringifyObject(r : Object, indent : String = "", curIndent : String = "") : String
		{
			var rs : String = "{\n";
			var ni : String = curIndent + indent;
			var ni2 : String = ni + indent;
			var akf : Boolean;

			var ks : Array = [];
			var ak : *;

			for (ak in r)
			{
				ks.push(ak);
			}

			ks.sort();

			for each (ak in ks)
			{
				var av : * = r[ak];

				if (akf)
				{
					rs += ",\n";
				}

				rs += ni + "\"" + ak + "\": ";
				rs += stringify(av, null, indent, ni);
				akf = true;
			}

			if (akf)
			{
				rs += "\n";
			}

			rs += curIndent + "}";
			return rs;
		}
	}
}

