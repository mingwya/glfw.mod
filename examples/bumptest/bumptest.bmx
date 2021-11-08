
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow

	Field image:TImage
	Field rot:Float

	Method New()
		Super.New( Null )
		
		'generate color texture
		Local colortex:TTexture=New TTexture( 256,256,PF_RGBA8888,TTexture.ClampST|TTexture.RenderTarget )
		Local rcanvas:TCanvas=New TCanvas( colortex )
		rcanvas.Clear( 1,1,1 )
		rcanvas.Flush

		'generate normal texture		
		Local normtex:TTexture=New TTexture( 256,256,PF_RGBA8888,TTexture.ClampST|TTexture.RenderTarget )
		rcanvas.RenderTarget( normtex )
		rcanvas.Clear( .5,.5,1.0,0.0 )
		For Local x:Int=0 Until 256 'Step 32
			For Local y:Int=0 Until 256 'Step 32
				
				Local dx:Float=x-127.5
				Local dy:Float=y-127.5
				Local dz:Float=127.5*127.5-dx*dx-dy*dy
				
				If dz<=0 Continue
				
				dz=Sqr( dz )
				
				Local r:Float=(dx+127.5)/255.0
				Local g:Float=(dy+127.5)/-255.0
				Local b:Float=(dz+127.5)/255.0
				
				rcanvas.Color( r,g,b,1 )
				rcanvas.DrawPoint( x,y )

			Next
		Next
		rcanvas.Flush

		Local material:TMaterial=New TMaterial( TShader.BumpShader() )
		material.SetTexture( "ColorTexture",colortex )
		material.SetTexture( "NormalTexture",normtex )
		material.SetVector( "AmbientColor",[0.0,0.0,0.0,1.0] )

		image=New TImage( material )
	End Method
	
	Method OnUpdate( dt:Float ) Override
		Super.OnUpdate()
		rot:+1.0*dt
	End Method
	
	Method OnRender( canvas:TCanvas ) Override
		canvas.AmbientLight .2,.2,.2
		
		canvas.LightType 0,1
		canvas.LightColor 0,.3,.3,.3
		canvas.LightPosition 0,Mouse.x(),Mouse.y(),-100
		canvas.LightRange 0,400
		
		'canvas.FogColor( 1,0,0,.5 )
		
		'rot:+.1
		'canvas.ResetMatrix()
		'canvas.Translate( 320,240 ) 'Width() Shr 1,Height() Shr 1 )
		'canvas.Rotate( rot )
		'canvas.RotateScale( rot,.5,.5 )
		
		canvas.DrawImage image,GraphicsWidth()/2,GraphicsHeight()/2,rot,.5,.5
	End Method
End Type

New TDeltaTimeApp
New TMyWindow

Repeat
	App.Update()
Forever

