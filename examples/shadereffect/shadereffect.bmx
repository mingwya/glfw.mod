
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow

	Field sourceImage:TImage=TImage.Load( "..\assets\default_player.png" )
	Field targetImage:TImage=New TImage( sourceImage.width(),sourceImage.height() )
	
	Field effect:TShaderEffect=New TShaderEffect
	
	Field level:Float=1
	
	Method New()
		Super.New( Null )
	End Method
	
	Method OnUpdate( dt:Float ) Override
		Super.OnUpdate( dt )
		If Key.Down( Key.A )
			level=Min( level+.01*dt,1.0 )
		Else If Key.Down( Key.Z )
			level=Max( level-.01*dt,0.0 )
		EndIf
	End Method
	
	Method OnRender( canvas:TCanvas ) Override

		effect.SetLevel level
		
		effect.Render( sourceImage,targetImage )
		
		canvas.Clear
		
		canvas.DrawImage targetImage,Mouse.X(),Mouse.Y()
		
		canvas.DrawText "Effect level="+level+" (A/Z to change)",0,0
	End Method
End Type

'Our custom shader
Type TBWShader Extends TShader
	
	'must implement this - sets valid/default material params
	Method OnInitMaterial( material:TMaterial ) Override
		material.SetTexture "ColorTexture",TTexture.White()
		material.SetScalar "EffectLevel",1
	End Method
	
	Function Instance:TBWShader()
		If Not _instance _instance=New TBWShader( LoadString( "..\assets\bwshader.glsl" ) )
		Return _instance
	End Function
	
	Private
	
	Global _instance:TBWShader
	
End Type

Type TShaderEffect

	Method New()
		If Not _canvas _canvas=New TCanvas(800,600)

		_material=New TMaterial( TBWShader.Instance() )
	End Method
	
	Method SetLevel( level:Float )
	
		_material.SetScalar "EffectLevel",level
	End Method
	
	Method Render( source:TImage,target:TImage )
	
		_material.SetTexture "ColorTexture",source.Material.ColorTexture()
		
		_canvas.RenderTarget target
		_canvas.Viewport 0,0,target.width(),target.height()
		_canvas.SetProjection2d 0,target.width(),0,target.height()
		
		_canvas.DrawRect 0,0,target.width(),target.height(),_material
		
		_canvas.Flush
	End Method
	
	'Private
	
	Global _canvas:TCanvas	'shared between ALL effects
	
	Field _material:TMaterial
	
End Type

New TDeltaTimeApp
New TMyWindow

Repeat
	App.Update()
Forever
