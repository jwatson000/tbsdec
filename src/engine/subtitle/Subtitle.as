package engine.subtitle
{
	

	public class Subtitle
	{
		public static const schema : Object =
			{
				name: "Subtitle",
				type: "object",
				properties: {
					text: {type: "string"},
					start: {type: "number"},
					end: {type: "number"}
				}
			};

		public var start : int = 0;
		public var end : int = 0;
		public var text : String;

		public function Subtitle()
		{
		}

		///

		public function fromJson(json : Object) : Subtitle
		{

			start = json.start;
			end = json.end;
			text = json.text;
			return this;
		}

		public function toJson() : Object
		{
			var r : Object =
				{
					start: start,
					end: end,
					text: text
				};

			return r;
		}

	}
}
