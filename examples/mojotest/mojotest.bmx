
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow
	
	Field ms:Int
	Field me:Int

	Field image:TImage=TImage.Load( "..\assets\RedbrushAlpha.png" )
	Field tx:Float
	Field ty:Float

	Field c:Int=7
	Field r:Int=255
	Field g:Int=255
	Field b:Int=255

	Field ang:Float = 0
	
	Method New()
		Super.New( Null )
	End Method
	
	Method OnUpdate( dt:Float ) Override
		Super.OnUpdate( dt )
		ang:+0.2*dt
	End Method
	
	Method OnRender( canvas:TCanvas ) Override
		ms=MilliSecs()
		canvas.Scissor 0,0,GraphicsWidth(),GraphicsHeight()
		canvas.Clear 0,0,.5
		
		Local sz:Float=Sinus(ang * 10)*32
		Local sx:Int=32+sz
		Local sy:Int=32
		Local sw:Int=GraphicsWidth()-(64+sz*2)
		Local sh:Int=GraphicsHeight()-(64+sz)
		
		canvas.Scissor sx,sy,sw,sh
		canvas.Clear 1,32.0/255.0,0

		canvas.PushMatrix()

		canvas.Translate tx,ty
		canvas.Scale GraphicsWidth()/640.0,GraphicsHeight()/480.0
		canvas.Translate 320,240
	'	canvas.Rotate MilliSecs()/1000.0*12
		canvas.Rotate ang
		canvas.Translate -320,-240
		
		canvas.Color .5,1,0
		canvas.DrawRect 32,32,640-64,480-64

		canvas.Color 1,1,0
		For Local y:Int=0 Until 480
			For Local x:Int=16 Until 640 Step 32
				canvas.Alpha Min( Abs( y-240.0 )/120.0,1.0 )
				canvas.DrawPoint x,y
			Next
		Next
		canvas.Alpha 1

		canvas.Color 0,.5,1
		canvas.DrawOval 64,64,640-128,480-128

		canvas.Color 1,0,.5
		canvas.DrawLine 32,32,640-32,480-32
		canvas.DrawLine 640-32,32,32,480-32

		canvas.Color r/255.0,g/255.0,b/255.0,Float(Sin(ang * 5)*.5+.5)
		canvas.DrawImage image,320,240,0
		canvas.Alpha 1

		canvas.Color 1,0,.5
		canvas.DrawPoly( [ 140.0,232.0, 320.0,224.0, 500.0,232.0, 500.0,248.0, 320.0,256.0, 140.0,248.0 ] )
				
		canvas.Color .5,.5,.5
		canvas.DrawText "The Quick Brown Fox Jumps Over The Lazy Dog",320,240,.5,.5
		

		canvas.PopMatrix()
		
		canvas.Flush()
		me = MilliSecs()

		'Print (me - ms)
	End Method
End Type

New TDeltaTimeApp
New TMyWindow

Repeat
	App.Update()
Forever
