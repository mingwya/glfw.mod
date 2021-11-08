
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow

	Field vertices:Float[]=New Float[4*2*100]
	Field indices:Int[]
	Field a:Float

	Method New()
		Super.New( Null )
		ClearColor( 0,0,1,1 )
		
		Local sz:Float=20.0
		Local p:Int=0

		For Local i:Int=0 Until 100

			'Local x:Float=Rnd(GraphicsWidth())-sz/2-GraphicsWidth()/2
			'Local y:Float=Rnd(GraphicsHeight())-sz/2-GraphicsHeight()/2
			Local x:Float=Rnd(800)-sz/2-800/2
			Local y:Float=Rnd(600)-sz/2-600/2
			
			vertices[p+0]=x
			vertices[p+1]=y
			
			vertices[p+2]=x+sz
			vertices[p+3]=y
			
			vertices[p+4]=x+sz
			vertices[p+5]=y+sz
			
			vertices[p+6]=x
			vertices[p+7]=y+sz
			
			p:+8
		Next

		'quick test of indices...
		indices = New Int[400]
		For Local i:Int=0 Until 400
			indices[i]=i
		Next
	End Method
	
	Method OnRender( canvas:TCanvas ) Override
		a:+0.001
		If a>1.0 Then a=0
		
		canvas.Color( ..
		Sinus( MilliSecs()*.01 )*.5+.5,Cosinus( MilliSecs()*.03 )*.5+.5,Sinus( MilliSecs()*.05 )*.5+.5,a )
	
		canvas.PushMatrix()
		canvas.Translate( Mouse.X(),Mouse.Y() )
		canvas.DrawIndexedPrimitives( 4,100,vertices,indices )	'should draw same thing...
		canvas.PopMatrix()
	End Method
End Type

New TDeltaTimeApp
New TMyWindow

Repeat
	App.Update()
Forever
