package brave;
import brave.cgdb.CgDb;
import brave.cgdb.CgDbEntry;
import brave.formats.BraveImage;
import brave.formats.Decrypt;
import brave.sound.SoundPack;
import haxe.io.Bytes;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.PixelSnapping;
import nme.errors.Error;
import nme.geom.Rectangle;
import nme.media.Sound;
import nme.utils.ByteArray;
import nme.utils.Endian;

#if cpp

import sys.io.File;

/**
 * ...
 * @author 
 */

class BraveAssets 
{
	static var voicePack:SoundPack;
	static var soundPack:SoundPack;
	static var cgDb:CgDb;

	public function new() 
	{
		
	}
	
	static public function getCgDbEntry(name:String):CgDbEntry {
		if (cgDb == null) {
			cgDb = new CgDb(Decrypt.decryptDataWithKey(getBytes("cgdb.dat"), Decrypt.key23));
		}
		return cgDb.get(name);
	}
	
	static public function getBitmap(name:String):Bitmap {
		return new Bitmap(getBitmapData(name), PixelSnapping.AUTO, true);
	}

	static public function getBitmapDataWithAlphaCombined(name:String):BitmapData {
		var mixed:BitmapData = getBitmapData(name);
		var width:Int = mixed.width;
		var hwidth:Int = Std.int(width / 2);
		var height:Int = mixed.height;
		var out:BitmapData = new BitmapData(hwidth, height, true);
		var color:ByteArray = mixed.getPixels(new Rectangle(0, 0, hwidth, height));
		var alpha:ByteArray = mixed.getPixels(new Rectangle(hwidth, 0, hwidth, height));
		
		color.position = 0;
		alpha.position = 0;
		
		for (n in 0 ... Std.int(color.length / 4)) {
			color[n * 4 + 0] = alpha[n * 4 +1];
		}
		
		out.setPixels(out.rect, color);
		
		return out;
	}

	static public function getBitmapData(name:String):BitmapData {
		var braveImage:BraveImage = new BraveImage();
		braveImage.load(BraveAssets.getBytes(Std.format("parts/${name}.CRP")));
		return braveImage.bitmapData;
	}

	static public function getSound(name:String):Sound {
		if (soundPack == null) {
			soundPack = new SoundPack(2, File.read(getBasePath() + "/sound.pck"));
		}
		return soundPack.getSound(name);
	}

	static public function getVoice(name:String):Sound {
		if (voicePack == null) {
			voicePack = new SoundPack(1, File.read(getBasePath() + "/voice/voice.pck"));
		}
		return voicePack.getSound(name);
	}
	
	static public function getMusic(name:String):Sound {
		var sound:Sound = new Sound();
		var bytes:ByteArray = getBytes("/midi/" + name + ".mid");
		//sound.loadPCMFromByteArray(
		sound.loadCompressedDataFromByteArray(bytes, bytes.length, true);
		return sound;
	}

	static private function getBasePath():String
	{
		return "C:/juegos/brave_s";
	}

	static public function getBytes(name:String):ByteArray
	{
		//return Assets.getBytes("assets/" + name);
		var bytes:Bytes = File.getBytes(getBasePath() + "/" + name);
		var byteArray:ByteArray = new ByteArray();
		byteArray.endian = Endian.LITTLE_ENDIAN;
		for (n in 0 ... bytes.length) byteArray.writeByte(bytes.get(n));
		byteArray.position = 0;
		return byteArray;
	}
}

#else

class BraveAssets 
{
	static var cgDb:CgDb;

	public function new() 
	{
		
	}
	
	static public function getCgDbEntry(name:String):CgDbEntry {
		if (cgDb == null) {
			cgDb = new CgDb(Decrypt.decryptDataWithKey(getBytes("cgdb.dat"), Decrypt.key23));
		}
		return cgDb.get(name);
	}
	
	static public function getBitmap(name:String):Bitmap {
		return new Bitmap(getBitmapData(name), PixelSnapping.AUTO, true);
	}

	static public function getBitmapDataWithAlphaCombined(name:String):BitmapData {
		var mixed:BitmapData = getBitmapData(name);
		var width:Int = mixed.width;
		var hwidth:Int = Std.int(width / 2);
		var height:Int = mixed.height;
		var out:BitmapData = new BitmapData(hwidth, height, true);
		var color:ByteArray = mixed.getPixels(new Rectangle(0, 0, hwidth, height));
		var alpha:ByteArray = mixed.getPixels(new Rectangle(hwidth, 0, hwidth, height));
		
		color.position = 0;
		alpha.position = 0;
		
		for (n in 0 ... Std.int(color.length / 4)) {
			color[n * 4 + 0] = alpha[n * 4 +1];
		}
		
		out.setPixels(out.rect, color);
		
		return out;
	}

	static public function getBitmapData(name:String):BitmapData {
		name = name.toUpperCase();
		var braveImage:BraveImage = new BraveImage();
		braveImage.load(BraveAssets.getBytes(Std.format("parts/${name}.CRP")));
		return braveImage.bitmapData;
	}

	static private function getDummySound():Sound {
		var sound:Sound = new Sound();
		var ba:ByteArray = new ByteArray();
		ba.writeFloat(0);
		ba.writeFloat(0);
		ba.position = 0;
		sound.loadPCMFromByteArray(ba, 1);
		return sound;
	}

	static public function getSound(name:String):Sound {
		return getDummySound();
	}

	static public function getVoice(name:String):Sound {
		return getDummySound();
	}
	
	static public function getMusic(name:String):Sound {
		return getDummySound();
	}

	static public function getBytes(name:String):ByteArray
	{
		var result:ByteArray = Assets.getBytes("assets/" + name);
		//if (result == null) throw(new Error(Std.format("Can't get assert '$name'")));
		if (result == null) throw(Std.format("Can't get assert '$name'"));
		return result;
	}
}

#end