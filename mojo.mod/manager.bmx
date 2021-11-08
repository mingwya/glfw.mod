

Public

Type TResManager
	
?Debug
	Global Debug:Int=False
?
	Method Delete()
		Free()
	End Method
	
	Method Free()
		For Local slug:String=EachIn slugs
			Local res:TRes=TRes( map[slug] ) '.ValueForKey( slug ) )
			If res Then res.Free()
		Next
		slugs=New TList
	End Method
	
	Method LoadPixmap:TPixmap( path:String )
		
		Local slug:String="pixmap:"+path
		
		Local pixmap:TPixmap=TPixmap( GetRes( slug ) )
		If pixmap Then Return pixmap
		
		pixmap=.LoadPixmap( path )
		If Not pixmap
			If Not nullPixmap
				nullPixmap:TPixmap=CreatePixmap( 32,32,PF_RGBA8888 )
				nullPixmap.ClearPixels( $FF0000FF )
			End If
			Return nullPixmap
		End If
		
		AddRes( pixmap,slug )
		
		Return pixmap
	End Method
	
	Method LoadTexture:TTexture( path:String,flags:Int=TTexture.Filter|TTexture.Mipmap|TTexture.ClampST )
		
		Local slug:String="texture:"+path+"&"+String( flags )
		
		Local texture:TTexture=TTexture( GetRes( slug ) )
		If texture Then Return texture
		
		Local pixmap:TPixmap=LoadPixmap( path )
		If Not pixmap Then Return Null
		texture=TTexture.Load( pixmap,flags ) 'New TTexture( pixmap.width,pixmap.height,flags,pixmap )
		
		AddRes( texture,slug )
		
		Return texture
	End Method
	
	Method LoadMaterial:TMaterial( path:String,flags:Int=TTexture.Filter|TTexture.Mipmap|TTexture.ClampST )',shader:TShader=Null )
		
		Local slug:String="material:"+path+"&"+String( flags )
		
		Local material:TMaterial=TMaterial( GetRes( slug ) )
		If material Then Return material
		
		Local texture:TTexture=LoadTexture( path,flags )
		If Not texture Then Return Null
		
		material=New TMaterial( Null ) 'shader
		material.SetTexture( "ColorTexture",texture )
		
		AddRes( material,slug )
		
		Return material
	End Method
	
	Method LoadImage:TImage( path:String,flags:Int=TImage.Filter|TImage.Mipmap )
		
		Local slug:String="image:"+path+"&"+String( flags )
		
		Local image:TImage=TImage( GetRes( slug ) )
		If image Then Return image
		
		Local material:TMaterial=LoadMaterial( path,flags )
		If Not material Then Return Null
		
		image=New TImage( material )
		
		AddRes( image,slug )
		
		Return image
	End Method
	
	Method LoadImage:TImage( path:String,x:Int,y:Int,width:Int,height:Int,flags:Int=TImage.Filter|TImage.Mipmap )
		
		Local slug:String="image:"+path+"&"+..
		String( x )+"&"+String( y )+"&"+String( width )+"&"+String( height )+"&"+String( flags )
		
		Local image:TImage=TImage( GetRes( slug ) )
		If image Then Return image
		
		Local material:TMaterial=LoadMaterial( path,flags )
		If Not material Then Return Null
		
		image=New TImage( material,x,y,width,height )
		
		AddRes( image,slug )
		
		Return image
	End Method
	
	Method LoadAnimImage:TImage[]( path:String,cellWidth:Int=0,cellHeight:Int=0,first:Int=0,count:Int=-1,flags:Int=TImage.Filter|TImage.Mipmap )
		
		Local slug:String="animimage:"+path+"&"+String( cellWidth )+"&"+String( cellHeight )+"&"+..
		String( first )+"&"+String( count )+"&"+String( flags )
		
		Local images:TImage[]=TImage[]( GetRes( slug ) )
		If images Then Return images
		
		Local material:TMaterial=LoadMaterial( path,flags )
		If Not material Then Return Null
		
		If cellWidth=<0 Then cellWidth=material.width()
		If cellHeight=<0 Then cellHeight=material.height()
		If count=<0 Then count=Int( material.width()/cellWidth )*Int( material.height()/cellHeight )
		
		Local x_cells:Int=material.width()/cellWidth
		Local y_cells:Int=material.height()/cellHeight
		If first+count>x_cells*y_cells Then Return Null
		
		'first=Min( first,x_cells*y_cells-1 )
		'count=Min( count )
		
		images=New TImage[count-first]
		
		For Local cell:Int=first Until first+count
			Local x:Int=cell Mod x_cells*cellWidth
			Local y:Int=cell/x_cells*cellHeight
			
			images[cell-first]=LoadImage( path,x,y,cellWidth,cellHeight,flags )
		Next
		
		AddRes( images,slug )
		
		Return images
	End Method
	
	Method LoadFont:TFont( path:String,flags:Int=TFont.Filter|TFont.Mipmap )
		
		Local slug:String="font:"+path+"&"+String( flags )
		
		Local font:TFont=TFont( GetRes( slug ) )
		If font Then Return font
		
		font=TFont.Load( path,flags )
		If Not font Then Return Null
		
		AddRes( font,slug )
		
		Return font
	End Method
	
	Method LoadFont:TFont( path:String,firstChar:Int,numChars:Int,padded:Int )
		
		Local slug:String="font:"+path+"&"+String( firstChar )+"&"+String( numChars )+"&"+String( padded )
		
		Local font:TFont=TFont( GetRes( slug ) )
		If font Then Return font
		
		font=TFont.Load( path,firstChar,numChars,padded )
		If Not font Then Return Null
		
		AddRes( font,slug )
		
		Return font
	End Method
	
	Method LoadFont:TFont( path:String,w:Int,h:Int,gx:Int,gy:Int,gw:Int,gh:Int,firstChar:Int,numChars:Int )
		
		Local slug:String="font:"+path+"&"+String( w )+"&"+String( h )+"&"+String( gx )+"&"+String( gy )+"&"+..
		String( gw )+"&"+String( gh )+"&"+String( firstChar )+"&"+String( numChars )
		
		Local font:TFont=TFont( GetRes( slug ) )
		If font Then Return font
		
		font=TFont.Load( path,w,h,gx,gy,gw,gh,firstChar,numChars )
		If Not font Then Return Null
		
		AddRes( font,slug )
		
		Return font
	End Method
	
	Rem
	Method LoadClass:TLuaClass( path:String )
		
		Local slug:String="class:"+path
		
		Local class:TLuaClass=TLuaClass( CheckRes( slug ) )
		If class Then Return class
		
		class=TLuaClass.Create( LoadText( path ) )
		If Not class Then Return Null
		
		AddRes( class,path )
		
		Return class
	End Method
	
	Method LoadAudioSample:TAudioSample( path:String )
		
		Local slug:String="sample:"+path
		
		Local sample:TAudioSample=TAudioSample( CheckRes( slug ) )
		If sample Then Return sample
		
		sample=.LoadAudioSample( path )
		If Not sample Then Return Null
		
		AddRes( sample,slug )
		
		Return sample
	End Method
	
	Method LoadSound:TSound( path:String,flags:Int )
		
		Local slug:String="sound:"+path+"&"+String( flags )
		
		Local sound:TSound=TSound( CheckRes( slug ) )
		If sound Then Return sound
		
		sound=.LoadSound( LoadAudioSample( path ) )
		If Not sound Then Return Null
		
		AddRes( sound,slug )
		
		Return sound
	End Method
	End Rem
	
	Protected
	
	Method GetRes:Object( slug:String )
		slug=slug.ToLower()
		
		mutex.Lock()
		Local res:TRes=TRes( map[slug] ) '.ValueForKey( slug ) )
		mutex.UnLock()
		
		If Not res Then Return Null
		
		If Not slugs.Contains( slug )
			slugs.AddLast( slug )
			'slugs:+[slug]
			res.Retain()
		End If
		
		Return res.obj
	End Method
	
	Method AddRes( obj:Object,slug:String )
		slug=slug.ToLower()
		
		mutex.Lock()
		'Assert Not map.Contains( slug ) And Not slugs.Contains( slug ),"Resource:"+slug+" - is already loaded."
		Assert Not map[slug] And Not slugs.Contains( slug ),"Resource:"+slug+" - is already loaded."
		Local res:TRes=New TRes( obj,slug )
		map[slug]=res '.Insert( slug,res )
		slugs.AddLast( slug )
		
		mutex.UnLock()
		
	End Method
	
	Private
	
	Global mutex:TMutex=TMutex.Create()
	Global map:THash=New THash
	
	Global nullPixmap:TPixmap
	
	Field slugs:TList=New TList
	'Field slugs:String[0]
End Type

Private

Type TRes Extends TRefCounted
	Field obj:Object
	Field slug:String
	
	Method New( obj:Object,slug:String="" )
		Self.obj=obj
		Self.slug=slug
?Debug
		If TResManager.Debug Then DebugLog( "Res.New:'"+slug+"'" )
?
	End Method
?Debug
	Method Retain() Override
		Super.Retain()
		If TResManager.Debug Then DebugLog( "Res:Retain:'"+slug+"'" )
	End Method
	
	Method Free() Override
		If TResManager.Debug Then DebugLog( "Res:UnRetain:'"+slug+"'" )
		Super.Free()
	End Method
?	

	Protected

	Method OnDestroy() Override
?Debug
		If TResManager.Debug Then DebugLog( "Res:Destroy:'"+slug+"'" )
?
		TResManager.map[slug]=Null '.Remove( slug )
		obj=Null
		slug=Null
	End Method
End Type
