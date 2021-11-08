
'***** Image *****

Public

Rem
bbdoc: An image is a rectangular area of pixels within a material, that can be drawn using one of the [[DrawList.DrawImage]] methods.
about: You can create a new image using one of the [[Image.Create]] methods, or load an image from file using [[Image.Load|Image.Load]].
An image also has a handle, an offset within the image that represents it's origin whan it is drawn. Image handles are specified in fractional values, where 0,0 is the top-left of an image, 1,1 is the bottom-right and .5,.5 is the center.
end rem
Type TImage

	Const Filter:Int=TTexture.Filter
	Const Mipmap:Int=TTexture.Mipmap
	Const Managed:Int=TTexture.Managed
	
	Global AutoMidHandle:Int=True
	
	Rem
	bbdoc: Creates a new image for rendering.
	about: The new image can be used as a render target for a [[Canvas]].
The @flags parameter can be any bitwise combination of:
| @Flags			| @Description
| TImage.Filter		| The image is filtered
| TImage.Mipmap		| The image is mipmapped
| TImage.Managed	| The image is managed
The TImage.Managed flag should be used if you want mojo2 to preserve the image contents when the graphics mode changes. This is not necessary if the image is being re-rendered every frame.
TImage.Managed consumes more memory, and slows down image rendering somewhat so should be avoided if possible.
	End Rem
	'Method Create:TImage( width:Int,height:Int,xhandle:Float=.5,yhandle:Float=.5,flags:Int=TImage.Filter )
	Method New( width:Int,height:Int,flags:Int=Filter )
		flags:&_flagsMask
		Local texture:TTexture=New TTexture( width,height,flags|TTexture.ClampST|TTexture.RenderTarget )
		_material=New TMaterial( Mojo._fastShader )
		_material.SetTexture( "ColorTexture",texture )
		_width=width
		_height=height
		If AutoMidHandle Then Handle( 0.5,0.5 )
	End Method
	
	Rem
	bbdoc: Creates a new image from a region within an existing image.
	about: The new image shares the same material and image flags as @image.
	End Rem
	Method New( image:TImage,x:Int,y:Int,width:Int,height:Int )
		_material=image._material
		_material.Retain()
		_x=image._x+x
		_y=image._y+y
		_width=width
		_height=height
		If AutoMidHandle Then Handle( 0.5,0.5 )
	End Method
	
	Rem
	bbdoc: Creates a new image from a material.
	End Rem
	Method New( material:TMaterial )
		Local texture:TTexture=material.ColorTexture()
		If Not texture Throw "Material has no ColorTexture"
		_material=material
		_material.Retain()
		_width=_material.Width()
		_height=_material.Height()
		If AutoMidHandle Then Handle( 0.5,0.5 )
	End Method

	Rem
	bbdoc: Creates a new image representing a rect within a material.
	End Rem
	Method New( material:TMaterial,x:Int,y:Int,width:Int,height:Int )
		Local texture:TTexture=material.ColorTexture()
		If Not texture Throw "Material has no ColorTexture"
		_material=material
		_material.Retain
		_x=x
		_y=y
		_width=width
		_height=height
		If AutoMidHandle Then Handle( 0.5,0.5 )
	End Method
	
	Rem
	bbdoc: Discards any internal resources such as videomem used by the image.
	End Rem
	Method Delete()
		If _material
			_material.Free()
			_material=Null
		End If
	End Method

	Rem
	bbdoc: Discards any internal resources such as videomem used by the image.
	End Rem
	'Method Discard()
	'	If _material _material.Free
	'	_material=Null
	'End Method
	
	Method Material:TMaterial()
		Return _material
	End Method
	
	Rem
	bbdoc: Gets x coordinate of the left edge of the image rect.
	End Rem
	Method X0:Float()
		Return _x0
	End Method
	
	Rem
	bbdoc: Gets y coordinate of the top edge of the image rect.
	End Rem
	Method Y0:Float()
		Return _y0
	End Method
	
	Rem
	bbdoc: Gets x coordinate of the right edge of the image rect.
	End Rem
	Method X1:Float()
		Return _x1
	End Method
	
	Rem
	bbdoc: Gets y coordinate of the bottom edge of the image rect.
	End Rem
	Method Y1:Float()
		Return _y1
	End Method
	
	Rem
	bbdoc: Gets image width.
	End Rem
	Method X:Int()
		Return _x
	End Method
	
	Rem
	bbdoc: Gets image width.
	End Rem
	Method Y:Int()
		Return _y
	End Method
	
	Rem
	bbdoc: Gets image width.
	End Rem
	Method Width:Int()
		Return _width
	End Method
	
	Rem
	bbdoc: Gets image height.
	End Rem
	Method Height:Int()
		Return _height
	End Method
	
	Rem
	bbdoc: Gets image x handle.
	End Rem
	'Method HandleX:Float()
	'	Return -_x0/(_x1-_x0)
	'End Method
	
	Rem
	bbdoc: Gets image y handle.
	End Rem
	'Method HandleY:Float()
	'	Return -_y0/(_y1-_y0)
	'End Method
	
	Method Handle:Float[]()
		Return [ -_x0/(_x1-_x0),-_y0/(_y1-_y0) ]
	End Method
	
	Method Handle( x:Float,y:Float )
		_x0=Float(_width)*-x
		_x1=Float(_width)*(1-x)
		_y0=Float(_height)*-y
		_y1=Float(_height)*(1-y)
		_s0=Float(_x)/Float(_material.Width())
		_t0=Float(_y)/Float(_material.Height())
		_s1=Float(_x+_width)/Float(_material.Width())
		_t1=Float(_y+_height)/Float(_material.Height())
	End Method
	
	Method Handle( xy:Float[] )
		Handle( xy[0],xy[1] )
	End Method
	
	'Method Handle( x:Int,y:Int )
	'	Handle( x/Float( Width() ),y/Float( Height() ) )
	'End Method
	
	'Method Handle( xy:Int[] )
	'	Handle( xy[0],xy[1] )
	'End Method
	
	Rem
	bbdoc: Writes pixel data to image.
	about: Pixels should be in premultiplied alpha format.
	End Rem
	Method WritePixels( x:Int,y:Int,width:Int,height:Int,data:TPixmap,dataOffset:Int=0,dataPitch:Int=0 )
		_material.ColorTexture().WritePixels( x+_x,y+_y,width,height,data,dataOffset,dataPitch )
	End Method
	
	Rem
	bbdoc: Set image shadow caster.
	about: Attaching a shadow caster to an image will cause the shadow caster to be automatically added to the
	drawlist whenever the image is drawn.
	End Rem
	Method ShadowCaster( shadowCaster:TShadowCaster )
		_caster=shadowCaster
	End Method
	
	Rem
	bbdoc: Gets attached shadow caster.
	End Rem
	Method ShadowCaster:TShadowCaster()
		Return _caster
	End Method
	
	Rem
	bbdoc: Sets an internal 'flags mask' that can be used to filter out specific image flags when creating images.
	about: The flags mask value is 'anded' with any flags values passed to Image.New, Image.Load or Image.LoadFrames.
	For example, by setting the flags mask to just Image.Managed, the Image.Filter and Image.Mipmap flags will be effectively disabled for all images - useful for pixel art or retro style graphics.
	The default flags mask is Image.Filter|Image.Mipmap|Image.Managed, which effectively disables the filter.
	End Rem
	Function FlagsMask( mask:Int )
		_flagsMask=mask
	End Function
	
	Rem
	bbdoc: Returns the current flags mask.
	End Rem
	Function FlagsMask:Int()
		Return _flagsMask
	End Function
	
	Rem
	bbdoc: 
	End Rem
	Function Load:TImage( url:Object,flags:Int=Filter|Mipmap,shader:TShader=Null )
		flags:&_flagsMask
	
		Local material:TMaterial=TMaterial.Load( url,flags|TTexture.ClampST,shader )
		If Not material Return Null

		Return New TImage( material )
	End Function
	
	Function Load:TImage[]( url:Object,cellWidth%,cellHeight%,first%=0,count%=-1,flags%=Filter|Mipmap,shader:TShader=Null )
		flags:&_flagsMask
		
		Local material:TMaterial=TMaterial.Load( url,flags|TTexture.ClampST,shader )
		If Not material Then Return Null
		
		If cellWidth<=0 Then cellWidth=material.width()
		If cellHeight<=0 Then cellHeight=material.height()
		If count<0 Then count=Int( material.width()/cellWidth )*Int( material.height()/cellHeight )
		
		Local x_cells:Int=material.width()/cellWidth
		Local y_cells:Int=material.height()/cellHeight
		If first+count>x_cells*y_cells Then Return Null
		
		Local images:TImage[]=New TImage[count-first]
		
		For Local cell:Int=first Until first+count
			Local x:Int=cell Mod x_cells*cellWidth
			Local y:Int=cell/x_cells*cellHeight
			
			images[cell-first]=New TImage( material,x,y,cellWidth,cellHeight )
		Next
		
		Return images
	End Function
	
	Function LoadSize:TImage[]( url:Object,numFrames:Int,padded:Int=False,flags:Int=Filter|Mipmap,shader:TShader=Null )
		flags:&_flagsMask
	
		Local material:TMaterial=TMaterial.Load( url,flags|TTexture.ClampST,shader )
		If Not material Return Null
		
		Local cellWidth:Int=material.Width()/numFrames
		Local cellHeight:Int=material.Height()
		
		Local x:Int=0
		Local width:Int=cellWidth
		If padded Then
			x:+1
			width:-2
		End If
		
		Local frames:TImage[]=New TImage[numFrames]
		
		For Local i:Int=0 Until numFrames
			frames[i]=New TImage( material,i*cellWidth+x,0,width,cellHeight )
		Next
		
		Return frames
	End Function
	
	Private
	
	Global _flagsMask:Int=Filter|Mipmap|Managed
	
	Field _material:TMaterial
	Field _x:Int,_y:Int,_width:Int,_height:Int
	
	Field _x0:Float=-1,_y0:Float=-1,_x1:Float=1,_y1:Float=1
	Field _s0:Float=0 ,_t0:Float=0 ,_s1:Float=1,_t1:Float=1

	Field _caster:TShadowCaster
End Type
