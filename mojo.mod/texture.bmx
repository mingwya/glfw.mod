
'***** Texture *****

Public

Rem
bbdoc: Textures contains image data for use by shaders when rendering.
about: For more information, please see the #TShader type.
end rem
Type TTexture Extends TRefCounted

	'flags
	Const Filter:Int=1
	Const Mipmap:Int=2
	Const ClampS:Int=4
	Const ClampT:Int=8
	Const ClampST:Int=12
	Const RenderTarget:Int=16
	Const Managed:Int=256

	Rem
	bbdoc: Creates a new texture.
	about: The @width and @height are parameters are the size of the new texture.
	The @format parameter must be 4.
	The @flags parameter can be a bitwise combination of:
	| @ Flags				| @Description
	| Texture.Filter			| The texture is filtered when magnified
	| Texture.Mipmap			| The texture is mipmapped when minified
	| Texture.ClampS			| Texture S coordinate is clamped
	| Texture.ClampT			| Texture T coordinate is clamped
	| Texture.ClampST		| Texture S and T coordinates are clamped.
	| Texture.RenderTarget	| The texture can rendered to using a #Canvas.
	| Texture.Managed		| Texture contents are preserved when graphics are lost
	End Rem
	'Method Create:TTexture( width:Int,height:Int,format:Int,flags:Int, data:TPixmap = Null )
	Method New( width:Int,height:Int,format:Int,flags:Int,data:TPixmap=Null )
		
		If format<>PF_RGBA8888
			Throw "Invalid texture format: "+format
		End If

		'can't mipmap NPOT textures on gles20
		If Not IsPow2( width ) Or Not IsPow2( height ) flags:&~Mipmap
		
		_width=width
		_height=height
		_format=format
		_flags=flags
		_data=data

		If _flags&Managed
			_managed=New TPixmap.Create( width,height,PF_RGBA8888 )
			If _data
				_managed.Paste( _data,0,0 )
				_data=Null
			Else
				_managed.ClearPixels( $ffff00ff )
			EndIf
		EndIf
		
		'Validate() 'thread safe!
	End Method
	
	Method New( width:Int,height:Int,flags:Int,data:TPixmap=Null )
		New( width,height,PF_RGBA8888,flags,data )
	End Method
	
	Method OnDestroy() Override
		'If _seq=Mojo.graphicsSeq Then glDeleteTextures( 1,Varptr _glTexture )
		glDeleteTextures( 1,Varptr _glTexture )
		_glTexture=0
		_glFramebuffer=0
	End Method
	
	Rem
	bbdoc: Gets texture width.
	end rem
	Method Width:Int()
		Return _width
	End Method
	
	Rem
	bbdoc: Gets texture height.
	end rem
	Method Height:Int()
		Return _height
	End Method
	
	Rem
	bbdoc: Gets texture format.
	end rem
	Method Format:Int()
		Return _format
	End Method
	
	Rem
	bbdoc: Gets texture flags.
	end rem
	Method Flags:Int()
		Return _flags
	End Method

	Rem
	bbdoc: Writes pixel data to texture.
	about: Pixels should be in premultiplied alpha format.
	end rem
	Method WritePixels( x:Int,y:Int,width:Int,height:Int,data:TPixmap,dataOffset:Int=0,dataPitch:Int=0 )

		glPushTexture2d( GLTexture() )
	
		If Not dataPitch Or dataPitch=width*4
			glTexSubImage2D( ..
			GL_TEXTURE_2D,0,x,y,width,height,GL_RGBA,GL_UNSIGNED_BYTE,data.pixels+dataOffset )
		Else
			For Local iy:Int=0 Until height
				glTexSubImage2D( ..
				GL_TEXTURE_2D,0,x,y+iy,width,1,GL_RGBA,GL_UNSIGNED_BYTE,data.pixels+dataOffset+iy*dataPitch )
			Next
		EndIf
		
		glPopTexture2d()
		
		If _flags&Managed
			Local texPitch:Int=_width*4
			If Not dataPitch Then dataPitch=width*4
			
			For Local iy:Int=0 Until height
				MemCopy( ..
				_data.pixels+( y+iy )*texPitch+x*4,data.pixels+dataOffset+iy*dataPitch,Size_T( width*4 ) )
			Next
		EndIf
	End Method

	Method Data( x:Int,y:Int,pixmap:TPixmap )
		
		If _managed
			If pixmap<>_managed Then _managed.Paste( pixmap,x,y )
		ElseIf _data
			If pixmap<>_data Throw "Texture is read only" 
		EndIf
		
		glPushTexture2d( GLTexture() )
		
		Local width:Int=pixmap.Width
		Local height:Int=pixmap.Height
		
		If pixmap.Pitch=_width*4
			glTexSubImage2D( GL_TEXTURE_2D,0,x,y,width,height,GL_RGBA,GL_UNSIGNED_BYTE,pixmap.pixels )
		Else
			For Local iy:Int=0 Until height
				glTexSubImage2D( ..
				GL_TEXTURE_2D,0,x,y+iy,width,1,GL_RGBA,GL_UNSIGNED_BYTE,pixmap.PixelPtr( 0,iy ) )
			Next
		EndIf
		
		glPopTexture2d()
	End Method
	
	Method Data:TPixmap()
		Return _data
	End Method
	
	Method UpdateMipmaps()
		If Not ( _flags&Mipmap ) Then Return
			
		'If _seq<>Mojo.graphicsSeq
		'	Validate()
		'	Return
		'EndIf

		glPushTexture2d( GLTexture() )
		glGenerateMipmap( GL_TEXTURE_2D )
		glPopTexture2d()
	End Method
	
	Method GLTexture:Int()
		Validate()
		Return _glTexture
	End Method
	
	Method GLFramebuffer:Int()
		Validate()
		Return _glFramebuffer
	End Method
	
	Rem
	bbdoc: Loads a texture from a url.
	end rem
	Function Load:TTexture( url:Object,flags:Int=Filter|Mipmap|ClampST )
	
		'Local info:Int[2]
		
		Local data:TPixmap=TPixmap( url )
		If Not data Then data=LoadPixmap( url )
		If Not data Return Null
		
		If data.format<>PF_RGBA8888 'convert to RGBA
			data=data.Convert( PF_RGBA8888 )
		End If
		
		PremultiplyAlpha( data )
		
		Return New TTexture( data.width,data.height,flags,data )
	End Function

	Function PremultiplyAlpha( pixmap:TPixmap ) NoDebug
        'loaded textures are all converted to PF_RGBA8888 before
        'so we can simply use this to skip ReadPixel/WritePixel and
        'format handling
		Local pixelPtr:Byte Ptr,x:Int,y:Int
        For y=0 Until pixmap.height
        For x=0 Until pixmap.width
            'format is: RGBA, 4 = bytes per pixel
            pixelPtr=pixmap.pixels+( y*pixmap.pitch+x*4 )
            pixelPtr[0]=( pixelPtr[0]&255 )*pixelPtr[3]/255 'r
            pixelPtr[1]=( pixelPtr[1]&255 )*pixelPtr[3]/255 'g
            pixelPtr[2]=( pixelPtr[2]&255 )*pixelPtr[3]/255 'b
            'pixelPtr[3]= pixelPtr[3]                        'a
        Next
        Next
    End Function
	
	Function Color:TTexture( color:Int )
		Local tex:TTexture=TTexture( _colors[String( color )] ) '.ValueForKey( color ) )
		If tex Then Return tex

		Local pixmap:TPixmap=New TPixmap.Create( 1,1,PF_RGBA8888 )
		pixmap.ClearPixels( color )

		tex=New TTexture( 1,1,PF_RGBA8888,ClampST,pixmap )
		_colors[String( color )]=tex '.Insert( color,tex )
		Return tex
	End Function
	
	Rem
	bbdoc: Returns a stock single texel black texture.
	end rem
	Function Black:TTexture()
		If Not _black _black=Color( $ff000000 )
		Return _black
	End Function
	
	Rem
	bbdoc: Returns a stock single texel white texture.
	end rem
	Function White:TTexture()
		If Not _white _white=Color( $ffffffff )
		Return _white
	End Function
	
	Rem
	bbdoc: Returnss a stock single texel magenta texture.
	end rem
	Function Magenta:TTexture()
		If Not _magenta _magenta=Color( $ffff00ff )
		Return _magenta
	End Function
	
	Rem
	bbdoc: Returns a stock single texel 'flat' texture for normal mapping.
	end rem
	Function Flat:TTexture()
		If Not _flat _flat=Color( $ff888888 )
		Return _flat
	End Function
	
	Private

	'Field _seq:Int
	Field _width:Int
	Field _height:Int
	Field _format:Int
	Field _flags:Int
	Field _data:TPixmap
	Field _managed:TPixmap
	
	Field _glTexture:Int
	Field _glFramebuffer:Int

	'Global _colors:TIntMap=New TIntMap
	Global _colors:THash=New THash
	
	Global _black:TTexture
	Global _white:TTexture
	Global _magenta:TTexture
	Global _flat:TTexture

	Method Validate()
		
		'If _seq=Mojo.graphicsSeq Then Return
		'If _seq Then Return
		'_seq=True 'Mojo.graphicsSeq
		
		If _glTexture Then Return
		
		Mojo.Init()
	
		glGenTextures( 1,Varptr _glTexture )
		
		glPushTexture2d( _glTexture )
		
		If _flags&Filter
			glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR )
		Else
			glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST )
		EndIf
		If ( _flags&Mipmap ) And ( _flags&Filter )
			glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR )
		ElseIf ( _flags&Mipmap )
			glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST_MIPMAP_NEAREST )
		ElseIf ( _flags&Filter )
			glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR )
		Else
			glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST )
		EndIf

		If _flags&ClampS Then glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE )
		If _flags&ClampT Then glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE )

		glTexImage2D( GL_TEXTURE_2D,0,GL_RGBA,_width,_height,0,GL_RGBA,GL_UNSIGNED_BYTE,Null )

		glPopTexture2d()
		
		If ( _flags&RenderTarget )
		
			glGenFramebuffers( 1,Varptr _glFramebuffer )
			
			glPushFramebuffer( _glFramebuffer )
			
			glBindFramebuffer( GL_FRAMEBUFFER,_glFramebuffer )
			glFramebufferTexture2D( GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,_glTexture,0 )
			
			If glCheckFramebufferStatus( GL_FRAMEBUFFER )<>GL_FRAMEBUFFER_COMPLETE
				Throw "Incomplete framebuffer"
			End If
			
			glPopFramebuffer()
		EndIf
		
		If _managed
			Data( 0,0,_managed )
			UpdateMipmaps()
		ElseIf _data
			Data( 0,0,_data )
			UpdateMipmaps()
		EndIf
	End Method
	
	Method LoadData( data:TPixmap )
		glPushTexture2d( GLTexture() )
		glTexImage2D( GL_TEXTURE_2D,0,GL_RGBA,_width,_height,0,GL_RGBA,GL_UNSIGNED_BYTE,data.pixels )
		glPopTexture2d()
		UpdateMipmaps()
	End Method
End Type
