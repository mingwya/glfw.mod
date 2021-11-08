
'***** Font *****

Public

Type TGlyph
	Field image:TImage
	Field char:Int
	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
	Field advance:Float
	Field offset:Int
	
	Method New( image:TImage,char:Int,x:Int,y:Int,width:Int,height:Int,advance:Float,offset:Int=0 )
		Self.image=image
		Self.char=char
		Self.x=x
		Self.y=y
		Self.width=width
		Self.height=height
		Self.advance=advance
		Self.offset=offset
	End Method
End Type

Rem
bbdoc: Provides support for simple fixed width bitmap fonts.
End Rem
Type TFontLoader Extends TStreamWrapper Abstract
	
	Method New()
		loaders=[Self]+loaders
	End Method
	
	Method Load:TFont( flags:Int ) Abstract
	
	Protected
	
	Global dir:String
	
	Private
	
	Global loaders:TFontLoader[0]
End Type

Rem
bbdoc: Provides support for simple fixed width bitmap fonts.
End Rem
Type TFont
	
	Const Filter:Int=TTexture.Filter
	Const Mipmap:Int=TTexture.Mipmap
	Const Managed:Int=TTexture.Managed
	
	Method New( glyphs:TGlyph[],firstChar:Int,height:Float )
		_glyphs=glyphs
		_firstChar=firstChar
		_height=height
	End Method

	Method GetGlyph:TGlyph( char:Int )
		Local i:Int=char-_firstChar
		If i>=0 And i<_glyphs.Length Return _glyphs[i]
		Return Null
	End Method
	
	Rem
	bbdoc: Gets width of @text drawn in this font.
	End Rem
	Method TextWidth:Float( text:String )
		Local w:Float=0,maxw:Float=0

		For Local char:Int=EachIn text
			
			Select char
			Case 10,13
				maxw=Max( w,maxw )
				w=0
				Continue
			End Select
			
			w:+TextWidth( char ) 'glyph.advance+glyph.offset
		Next
		Return w
	End Method
	
	Rem
	bbdoc: Gets width of @char drawn in this font.
	End Rem
	Method TextWidth:Float( char:Int )
		Local glyph:TGlyph=GetGlyph( char )
		If Not glyph Then Return 0
		Return glyph.advance+glyph.offset
	End Method

	Rem
	bbdoc: Gets height of @text drawn in this font.
	End Rem
	Method TextHeight:Float( text:String )
		Local lines:String[]=text.Split( "~n" )
		Return lines.Length*_height+( lines.Length-1 )*_lineKerning
	End Method
	
	Rem
	bbdoc: Gets height of @char drawn in this font.
	End Rem
	Method TextHeight:Float( char:Int )
		Return _height
	End Method
	
	Rem
	bbdoc: Gets width and height of @text drawn in this font.
	End Rem
	Method TextSize:Float[]( text:String )
		Local w:Float=0
		
		Local size:Float[]=[0.0,0.0]
		
		For Local char:Int=EachIn text
			
			Select char
			Case 10,13
				size[0]=Max( w,size[0] )
				size[1]:+_height+_lineKerning
				Continue
			End Select
			
			'Local glyph:TGlyph=GetGlyph( char )
			'If Not glyph Continue
			
			w:+TextWidth( char ) 'glyph.advance+glyph.offset
		Next
		Return size
	End Method
	
	Rem
	bbdoc: Gets width of @text drawn in this font.
	End Rem
	Method FormatText:String( text:String,maxWidth:Float )
		text=text.Replace( "~n","" )
		
		Local lines:String[]=_format( text,maxWidth )
		
		text=""
		For Local line:String=EachIn lines
			text:+line+"~n"
		Next
		Return text
	End Method
	
	Rem
	bbdoc: Gets width of @text drawn in this font.
	End Rem
	Method LineKerning( kerning:Float )
		_lineKerning=kerning
	End Method
	
	Rem
	bbdoc: Gets width of @text drawn in this font.
	End Rem
	Method LineKerning:Float()
		Return _lineKerning
	End Method
	
	Rem
	bbdoc: Loads a fixed width font from @path.
	about: Glyphs should be laid out horizontally within the source image.
	If @padded is true, then each glyph is assumed to have a transparent one pixel padding border around it.
	End Rem
	Function Load:TFont( url:Object,firstChar:Int,numChars:Int,padded:Int )

		Local image:TImage=TImage.Load( url )
		If Not image Return Null
		
		Local cellWidth:Int=image.Width()/numChars
		Local cellHeight:Int=image.Height()
		Local glyphX:Int=0,glyphY:Int=0,glyphWidth:Int=cellWidth,glyphHeight:Int=cellHeight
		If padded glyphX:+1;glyphY:+1;glyphWidth:-2;glyphHeight:-2

		Local w:Int=image.Width()/cellWidth
		Local h:Int=image.Height()/cellHeight

		Local glyphs:TGlyph[]=New TGlyph[numChars]
		
		For Local i:Int=0 Until numChars
			Local y:Int=i / w
			Local x:Int=i Mod w
			Local glyph:TGlyph=New TGlyph( image,firstChar+i,x*cellWidth+glyphX,y*cellHeight+glyphY,glyphWidth,glyphHeight,glyphWidth )
			glyphs[i]=glyph
		Next
		
		Return New TFont( glyphs,firstChar,glyphHeight )
	End Function
	
	Function Load:TFont( url:Object,flags:Int=Filter|Mipmap )
		TFontLoader.dir=ExtractDir( String( url ) )
		If TFontLoader.dir<>"" Then TFontLoader.dir=TFontLoader.dir+"/"
		
		Local stream:TStream=ReadStream( url ),font:TFont=Null
		
		For Local loader:TFontLoader=EachIn TFontLoader.loaders
			loader.SetStream( stream )
			font=loader.Load( flags )
			loader.SetStream( Null )
			If font Then Exit
		Next
		Return font
	End Function
	
	Function Load:TFont( url:Object,cellWidth:Int,cellHeight:Int,glyphX:Int,glyphY:Int,glyphWidth:Int,glyphHeight:Int,firstChar:Int,numChars:Int )

		Local image:TImage=TImage.Load( url )
		If Not image Return Null

		Local w:Int=image.Width()/cellWidth
		Local h:Int=image.Height()/cellHeight

		Local glyphs:TGlyph[]=New TGlyph[numChars]
		
		For Local i:Int=0 Until numChars
			Local y:Int=i / w
			Local x:Int=i Mod w
			Local glyph:TGlyph=New TGlyph( image,firstChar+i,x*cellWidth+glyphX,y*cellHeight+glyphY,glyphWidth,glyphHeight,glyphWidth )
			glyphs[i]=glyph
		Next
		
		Return New TFont( glyphs,firstChar,glyphHeight )
	End Function
	
	Function SetTags( open:Int,Close:Int )
		openTag=Chr( open )
		openTagAsc=open
		closeTag=Chr( Close )
		closeTagAsc=Close
	End Function
	
	Function SetTags( open:String,Close:String )
		openTag=open[..1]
		openTagAsc=Asc( openTag )
		closeTag=Close[..1]
		closeTagAsc=Asc( closeTag )
	End Function
	
	Method Shadowed( state:Int )
		_shadow=( state>0 )
	End Method
	
	Method Shadowed:Int()
		Return _shadow
	End Method
	
	Method ShadowColor( r:Float,g:Float,b:Float,a:Float=1.0 ) ',offsetX:Float,offsetY:Float )
		_shadowColor[0]=r
		_shadowColor[1]=g
		_shadowColor[2]=b
		_shadowColor[3]=a
	End Method
	
	Method ShadowOffset( x:Float,y:Float )
		_shadowOffset[0]=x
		_shadowOffset[1]=y
	End Method
	
	Private
	
	Global openTag:String="<"
	Global closeTag:String=">"
	Global openTagAsc:Int=60
	Global closeTagAsc:Int=62
	
	Field _shadow:Int
	Field _shadowColor:Float[4]
	Field _shadowOffset:Float[2]
	
	Field _glyphs:TGlyph[]
	Field _firstChar:Int
	Field _height:Float
	Field _lineKerning:Float
	
	Method _format:String[]( text:String,maxWidth:Float )
		Local lines:String[]
		
		Local startPos:Int,endPos:Int=-1
		
		Local width:Float,inTag:Int
		For Local i:Int=0 Until text.Length
			Local char:Int=text[i]
			
			Select char
			Case 32
				If Not inTag Then endPos=i
			Case openTagAsc
				inTag=True
				Continue
			Case closeTagAsc
				inTag=False
				Continue
			Case 9,10
				Continue
			End Select
			
			If inTag Then Continue
			
			width:+TextWidth( char )
			
			If width>=maxWidth And endPos<>-1
				width=0
				lines:+[ text[startPos..endPos] ]
				i=endPos+1
				startPos=i
				endPos=-1
			EndIf
		Next
		
		lines:+[ text[startPos..] ]
		
		Return lines
	End Method
End Type
