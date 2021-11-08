
SuperStrict

Import BRL.Math
Import BRL.Pixmap
Import BRL.RandomDefault

Public

Struct SColorF
	Global None:SColorF		=New SColorF( 0,0,0,0 )
	Global Black:SColorF	=New SColorF( 0,0,0 )
	Global Grey:SColorF		=New SColorF( .5,.5,.5 )
	Global LightGrey:SColorF=New SColorF( .75,.75,.75 )
	Global DarkGrey:SColorF	=New SColorF( .25,.25,.25 )
	Global White:SColorF	=New SColorF( 1,1,1 )
	Global Red:SColorF		=New SColorF( 1,0,0 )
	Global Green:SColorF	=New SColorF( 0,1,0 )
	Global Blue:SColorF		=New SColorF( 0,0,1 )
	Global Brown:SColorF	=New SColorF( .7,.4,.1 )
	Global Orange:SColorF	=New SColorF( 1,.5,0 )
	Global Yellow:SColorF	=New SColorF( 1,1,0 )
	Global Lime:SColorF		=New SColorF( .7,1,0 )
	Global Pine:SColorF		=New SColorF( 0,.5,0 )
	Global Aqua:SColorF		=New SColorF( 0,.9,.4 )
	Global Cyan:SColorF		=New SColorF( 0,1,1 )
	Global Sky:SColorF		=New SColorF( 0,.5,1 )
	Global Steel:SColorF	=New SColorF( .2,.2,.7 )
	Global Violet:SColorF	=New SColorF( .7,0,1 )
	Global Magenta:SColorF	=New SColorF( 1,0,1 )
	Global Puce:SColorF		=New SColorF( 1,0,.4 )
	Global Skin:SColorF		=New SColorF( .8,.5,.6 )
	Global Pink:SColorF		=New SColorF( 1,.75,.8 )
	Global HotPink:SColorF	=New SColorF( 1,.41,.71 )
	Global SeaGreen:SColorF	=New SColorF( .031372,.301960,.247058 )
	Global Silver:SColorF	=New SColorF( 0.98695202723239916,0.98157612499486091,0.96058105436290453 )
	Global Aluminum:SColorF	=New SColorF( 0.95955910300613745,0.9635188914336692,0.96495768667887971 )
	Global Gold:SColorF		=New SColorF( 1,0.88565078560356991,0.6091625017721024 )
	Global Copper:SColorF	=New SColorF( 0.9792921449434141,0.81490079942355442,0.75455014940288267 )
	Global Chromium:SColorF	=New SColorF( 0.76178782381338439,0.76588820797089974,0.76472402871006473 )
	Global Nickel:SColorF	=New SColorF( 0.827766413700323,0.79798492878548577,0.74652364685504802 )
	Global Titanium:SColorF	=New SColorF( 0.75694694835172049,0.72760746687141564,0.69520723368860826 )
	Global Cobalt:SColorF	=New SColorF( 0.82910355988659823,0.82495893307721546,0.81275025476652396 )
	Global Platinum:SColorF	=New SColorF( 0.83493408973507777,0.81484503266020314,0.78399912482207756 )

	Field ReadOnly r:Float=1.0
	Field ReadOnly g:Float=1.0
	Field ReadOnly b:Float=1.0
	Field ReadOnly a:Float=1.0
	
	Method New( color:Int,format:Int=PF_RGBA )
		Select format
		Case PF_RGB
			r=( color Shr 24 & $FF )/255.0
			g=( color Shr 16 & $FF )/255.0
			b=( color Shr  8 & $FF )/255.0
		Case PF_BGR
			b=( color Shr 24 & $FF )/255.0
			g=( color Shr 16 & $FF )/255.0
			r=( color Shr  8 & $FF )/255.0
		Case PF_RGBA
			r=( color Shr 24 & $FF )/255.0
			g=( color Shr 16 & $FF )/255.0
			b=( color Shr  8 & $FF )/255.0
			a=( color&$FF )/255.0
		Case PF_BGRA
			b=( color Shr 24 & $FF )/255.0
			g=( color Shr 16 & $FF )/255.0
			r=( color Shr  8 & $FF )/255.0
			a=( color&$FF )/255.0
		End Select
	End Method
	
	Method New( a:Float )
		Self.a=a
	End Method
	
	Method New( i:Float,a:Float )
		r=i
		g=i
		b=i
		Self.a=a
	End Method
	
	Method New( r:Float,g:Float,b:Float,a:Float=1 )
		Self.r=r
		Self.g=g
		Self.b=b
		Self.a=a
	End Method
	
	Method ToString:String()
		Return "Color( "+r+","+g+","+b+","+a+" )"
	End Method
	
	Method Operator*:SColorF( color:SColorF )
		Return New SColorF( r*color.r,g*color.g,b*color.b,a*color.a )
	End Method
	
	Method Operator*:SColorF( scalar:Float )
		Return New SColorF( r*scalar,g*scalar,b*scalar,a*scalar )
	End Method
	
	Method Operator/:SColorF( color:SColorF )
		Return New SColorF( r/color.r,g/color.g,b/color.b,a/color.a )
	End Method
	
	Method Operator/:SColorF( scalar:Float )
		Local iscalar:Float=1.0/scalar
		Return New SColorF( r*iscalar,g*iscalar,b*iscalar,a*iscalar )
	End Method
	
	Method Operator+:SColorF( color:SColorF )
		Return New SColorF( r+color.r,g+color.g,b+color.b,a+color.a )
	End Method
	
	Method Operator+:SColorF( scalar:Float )
		Return New SColorF( r+scalar,g+scalar,b+scalar,a+scalar )
	End Method
	
	Method Operator-:SColorF( color:SColorF )
		Return New SColorF( r-color.r,g-color.g,b-color.b,a-color.a )
	End Method
	
	Method Operator-:SColorF( scalar:Float )
		Return New SColorF( r-scalar,g-scalar,b-scalar,a-scalar )
	End Method
	
	Method Operator=:Int( color:SColorF )
		Return r=color.r And g=color.g And b=color.b And a=color.a
	End Method
	
	Method Operator[]:Float( index:Int )
		Select index
		Case 0 Return r
		Case 1 Return g
		Case 2 Return b
		Default Return a
		End Select
	End Method
	
	Method Blend:SColorF( color:SColorF,d:Float )
		Local id:Float=1.0-d
		Return New SColorF( r*id+color.r*d,g*id+color.g*d,b*id+color.b*d,a*id+color.a*d )
	End Method
	
	Method ToARGB:Int()
		Return Int( a*255 ) Shl 24 | Int( r*255 ) Shl 16 | Int( g*255 ) Shl 8 | Int( b*255 )
	End Method
	
	Method ToBGRA:Int()
		Return Int( b*255 ) Shl 24 | Int( g*255 ) Shl 16 | Int( r*255 ) Shl 8 | Int( a*255 )
	End Method
	
	Method ToRGBA:Int()
		Return Int( r*255 ) Shl 24 | Int( g*255 ) Shl 16 | Int( b*255 ) Shl 8 | Int( a*255 )
	End Method
	
	Method ToABGR:Int()
		Return Int( a*255 ) Shl 24 | Int( b*255 ) Shl 16 | Int( g*255 ) Shl 8 | Int( r*255 )
	End Method
	
	Function FromHSV:SColorF( h:Float,s:Float,v:Float,a:Float=1.0 )
		h:*6
		
		Local f:Float=Float( h-Floor( h ) )
		
		Local p:Float=v*( 1.0-s )
		Local q:Float=v*( 1.0-( s*f ) )
		Local t:Float=v*( 1.0-( s*( 1.0-f ) ) )
		
		Local r:Float,g:Float,b:Float
		
		Select Int(h) Mod 6
		Case 0 r=v ; g=t ; b=p
		Case 1 r=q ; g=v ; b=p
		Case 2 r=p ; g=v ; b=t
		Case 3 r=p ; g=q ; b=v
		Case 4 r=t ; g=p ; b=v
		Case 5 r=v ; g=p ; b=q
		End Select
		
		Return New SColorF( r,g,b,a )
	End Function
	
	Rem
	Function FromARGB:SColorF( argb:UInt )
		Local a:Float=( argb Shr 24 & $FF )/255.0
		Local r:Float=( argb Shr 16 & $FF )/255.0
		Local g:Float=( argb Shr  8 & $FF )/255.0
		Local b:Float=( argb&$FF )/255.0
		Return New SColorF( r,g,b,a )
	End Function
	
	Function FromBGRA:SColorF( bgra:UInt )
		Local b:Float=( bgra Shr 24 & $FF )/255.0
		Local g:Float=( bgra Shr 16 & $FF )/255.0
		Local r:Float=( bgra Shr  8 & $FF )/255.0
		Local a:Float=( bgra&$FF )/255.0
		Return New SColorF( r,g,b,a )
	End Function
	
	Function FromRGBA:SColorF( rgba:UInt )
		Local r:Float=( rgba Shr 24 & $FF )/255.0
		Local g:Float=( rgba Shr 16 & $FF )/255.0
		Local b:Float=( rgba Shr  8 & $FF )/255.0
		Local a:Float=( rgba&$FF )/255.0
		Return New SColorF( r,g,b,a )
	End Function
	
	Function FromABGR:SColorF( abgr:UInt )
		Local a:Float=( abgr Shr 24 & $FF )/255.0
		Local b:Float=( abgr Shr 16 & $FF )/255.0
		Local g:Float=( abgr Shr  8 & $FF )/255.0
		Local r:Float=( abgr&$FF )/255.0
		Return New SColorF( r,g,b,a )
	End Function
	End Rem
	
	Function Rnd:SColorF()
		Return FromHSV( Float( .Rnd( 6 ) ),1,1 )
	End Function
End Struct
