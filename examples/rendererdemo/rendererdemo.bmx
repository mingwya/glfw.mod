
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow
	
	Const NUM_LIGHTS:Int = 5

	'Local canvas:TCanvas = New TCanvas
	'canvas.Viewport( 0,0,GraphicsWidth(),GraphicsHeight())
	'canvas.ProjectionMatrix( Mat4Ortho( 0,640,0,480,-1,1 ) )

	Field tile:TImage
	Field shadowCaster:TShadowCaster
	Field renderer:TRenderer
	Field layer0:TMyLayer
	Field rimage:TImage
	
	Field angle:Float = 0

	Field ms:Int, me:Int
	
	Method New()
		Super.New( Null )
		
		'create renderer
		renderer=New TRenderer
		renderer.SetAmbientLight( [0.1,0.1,0.1,1.0] )

		'load some gfx
		tile=TImage.Load( "../assets/t3.png" )',0.0,0.0 )
		tile.handle( 0.0,0.0 )

		'create layer 0
		layer0=New TMyLayer

		'add some lights to layer
		For Local i:Int=0 Until NUM_LIGHTS
			Local light:TMyLight = New TMyLight
			light.color[i Mod 3]=0.5
			layer0.lights.Push( light )
		Next

		For Local x:Int=0 To 128*6 Step 128
		For Local y:Int=0 To 128*5 Step 128	
			layer0.DrawImage( tile,x,y )
		Next
		Next

		'create simple rect shadow caster
		shadowCaster=New TShadowCaster( [0.0,0.0, 32.0,0.0, 32.0,32.0, 0.0,32.0] )

		'draw some shadow casters
		For Local x:Int=180 Until 800 Step 220
		For Local y:Int=120 Until 600 Step 180
	
			layer0.Color( 1,1,0 )
			layer0.DrawRect( x-16,y-16,32,32 )
			layer0.Color( 1,1,1 )
		
			layer0.AddShadowCaster( shadowCaster,x-16,y-16 )
		Next
		Next

		'add layer to renderer		
		renderer.Layers.Push layer0
	End Method
	
	Method OnUpdate( dt:Float )
		Super.OnUpdate( dt )
		angle:+0.5*dt
	End Method
	
	Method OnRender( canvas:TCanvas ) Override
		
		'canvas.Viewport( 0,0,800,600 ) 'GraphicsWidth(),GraphicsHeight())
		'canvas.ProjectionMatrix( Mat4Ortho( 0,800,0,600,-1,1 ) )
		
		'move lights around a bit
		For Local i:Int=0 Until NUM_LIGHTS
			Local light:TMyLight=TMyLight(layer0.lights.Get(i))
			Local radius:Float=120.0
			'Local an:Float=(i*360.0/NUM_LIGHTS)+(MilliSecs()/50.0)
			Local an:Float=(i*360.0/NUM_LIGHTS)+(angle)
			light.matrix[12]=Cosinus( an )*radius+400
			light.matrix[13]=Sinus( an )*radius+300
		Next
		'render scene
		renderer.Render( canvas )
		
	End Method
End Type

New TDeltaTimeApp
New TMyWindow

Repeat
	app.Update()
Forever

'create an orthographics projection matrix
Function Mat4Ortho:Float[]( Left:Float,Right:Float,bottom:Float,top:Float,znear:Float,zfar:Float )
	Local w:Float=Right-Left,h:Float=top-bottom,d:Float=zfar-znear
	Return [ 2.0/w,.0,.0,.0, .0,2.0/h,.0,.0, .0,.0,2.0/d,.0, -(Right+Left)/w,-(top+bottom)/h,-(zfar+znear)/d,1.0 ]
End Function

Type TMyLight Implements ILight

	'note: x,y,z,w go in last 4 components of matrix...
	Field matrix:Float[]=[1.0,0.0,0.0,0.0, 0.0,1.0,0.0,0.0, 0.0,0.0,1.0,0.0, 0.0,0.0,-100.0,1.0]
	Field color:Float[]=[0.2,0.2,0.2,1.0]
	Field Range:Float=400.0

	'implement ILight interface...
	'
	Method LightMatrix:Float[]()
		Return matrix
	End Method
	
	Method LightType:Int()
		Return 1
	End Method
	
	Method LightColor:Float[]()
		Return color
	End Method
	
	Method LightRange:Float()
		Return Range
	End Method
	
	Method LightImage:TImage()
		Return Null
	End Method
End Type

Type TMyLayer Extends TDrawList Implements ILayer

	Field lights:TILightStack=New TILightStack
	Field _layerMatrix:Float[]=[1.0,0.0,0.0,0.0, 0.0,1.0,0.0,0.0, 0.0,0.0,1.0,0.0, 0.0,0.0,0.0,1.0]
	Field _layerFogColor:Float[]=[0.0,0.0,0.0,0.0]

	'implement ILayer interface...
	'
	Method LayerMatrix:Float[]()
		Return _layerMatrix
	End Method
	
	Method LayerFogColor:Float[]()
		Return _layerFogColor
	End Method
	
	Method LayerLightMaskImage:TImage()
		Return Null
	End Method
	
	Method EnumLayerLights( lights:TILightStack )
		For Local i:Int = 0 Until Self.lights.length
			lights.Push Self.lights.Get(i)
		Next
	End Method

	Method OnRenderLayer( drawLists:TDrawListStack )
		drawLists.Push( Self )
	End Method
End Type
