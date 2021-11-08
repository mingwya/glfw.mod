
Private

Type TFontLoader_HGE Extends TFontLoader { version="0.3" }
	Method Load:TFont( flags:Int ) Override
		
		If ReadLine().ToUpper()<>"[HGEFONT]" Then Return Null
		
		Local image:TImage, glyphs:TGlyph[256], maxh:Int=-1', minc:Int
		
		While Not Eof()
			
			Local line:String=ReadLine()
			
			If Not image
				If line.StartsWith( "Bitmap=" )
					Local file:String=line.Split( "=" )[1]
					image=TImage.Load( dir+file,flags )
				End If
				Continue
			End If
			
			If Not line.StartsWith( "Char=" ) Then Continue
			
			line=line[5..]
			
			Local a:Byte=False
			
			If line.StartsWith( "~q," )
				Line=Line[2..]
				a=True
			End If
			
			Local array:String[]=line.Split( "," )
			
			If a
				array[0]="~q,"+array[0]
				a=False
			End If
			
			Local ident:String = array[0]'.Replace("~q", "")
			
			Local char:Int
			
			If ident.StartsWith( "~q" )
				ident=ident[1..]
				ident=ident[..1]
				char=Asc( ident )
			Else
				char=( "$"+ident ).ToInt()
			End If
			
			glyphs[char]=New TGlyph( ..
				image,..
				char,..
				array[1].ToInt(),..
				array[2].ToInt(),..
				array[3].ToInt(),..
				array[4].ToInt(),..
				array[3].ToInt()+array[6].ToInt(),..
				array[5].ToInt() )
			
			maxh=Max( maxh,array[4].ToInt() )
		Wend
		
		Return New TFontHGE( glyphs,0,maxh )
	End Method
End Type
New TFontLoader_HGE

Type TFontHGE Extends TFont
	Method GetGlyph:TGlyph( char:Int ) Override
		If char>255
			char=char Mod 256
			char:+176
		End If
		Return Super.GetGlyph( char )
	End Method
End Type
