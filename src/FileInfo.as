package
{
	import flash.utils.ByteArray;

	import engine.subtitle.SubtitleSequence;

	public class FileInfo
	{
		public var filename : String;
		public var text : String;
		public var isJson : Boolean;
		public var isSbv : Boolean;
		public var isCompressed : Boolean;
		public var isOrig : Boolean;

		private static var SUFFIX_Z : String = ".z";
		private static var SUFFIX_CLIP : String = ".clip";
		private static var SUFFIX_TXT : String = ".txt";
		private static var SUFFIX_JSON : String = ".json";
		private static var SUFFIX_SBV : String = ".sbv";
		private static var SUFFIX_ORIG : String = ".orig";

		public function FileInfo()
		{
		}

		public static function ctor(url : String, data : ByteArray) : FileInfo
		{
			var fi : FileInfo = new FileInfo;
			var jo : Object;

			if (url.indexOf(SUFFIX_ORIG) == (url.length - SUFFIX_ORIG.length))
			{
				fi.isOrig = true;
				// strip off ".orig" -- we are restoring from backup
				url = url.substr(0, url.length - SUFFIX_ORIG.length);
			}

			fi.filename = url;

			if (url.indexOf(SUFFIX_Z) == (url.length - SUFFIX_Z.length))
			{
				fi.isCompressed = true;
				data.uncompress();
				url = url.substr(0, url.length - SUFFIX_Z.length);
			}

			if (url.indexOf(SUFFIX_CLIP) == (url.length - SUFFIX_CLIP.length))
			{
				fi.isCompressed = true;
				data.uncompress();
			}

			if (url.indexOf(SUFFIX_TXT) == (url.length - SUFFIX_TXT.length))
			{
				fi.text = data.readUTFBytes(data.bytesAvailable);
				return fi;
			}

			if (url.indexOf(SUFFIX_JSON) == (url.length - SUFFIX_JSON.length) ||
				url.indexOf(SUFFIX_CLIP) == (url.length - SUFFIX_CLIP.length))
			{
				fi.isJson = true;
				jo = data.readObject();
				fi.text = StableJson.stringify(jo, null, "  ");
				return fi;
			}

			if (url.indexOf(SUFFIX_SBV) == (url.length - SUFFIX_SBV.length))
			{
				fi.isSbv = true;

				jo = data.readObject();
				var sbs : SubtitleSequence = new SubtitleSequence().fromJson(jo);
				fi.text = sbs.toSbv();
				return fi;
			}

			return null;
		}
	}
}
