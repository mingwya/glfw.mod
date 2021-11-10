
Rem
{ console }
{ console=aliasName }

or

cmdFunc( args.. )
End Rem

Public

Function Print( str:String,timer:Int )
	New STimedString( str,timer*1000 )
End Function

Function Print( str:String,timer:Float )
	New STimedString( str,Int( timer*1000.0 ) )
End Function

Private

Type STimedString
	
	Global list:TList=New TList
	
	Field str:String
	Field endTime:Int
	
	Method New( str:String,timer:Int )
		Self.str=str
		list.AddFirst( Self )
		endTime=MilliSecs()+timer
	End Method
	
	Function Update()
		For Local s:STimedString=EachIn list
			If MilliSecs()>s.endTime
				list.Remove( s )
			End If
		Next
	End Function
	
	Function Draw( canvas:TCanvas )
		canvas.PushMatrix()
		canvas.ResetMatrix()
		
		'Local v:Int[]=canvas.Viewport()
		'Local y:Float=canvas.Height()-16 'App.GraphicsHeight-16
		
		Local y:Float=0
		If App.ActiveWindow() '.GraphicsHeight()-16
			y=App.ActiveWindow().GraphicsHeight()-16
		End If
		For Local s:STimedString=EachIn list
			
			canvas.DrawText( s.str,5.0,y )
			y:-16
			
		Next
		
		canvas.PopMatrix()
	End Function
End Type

Type TConsoleStream Extends TStream 'Wrapper
	Method WriteLine:Int(str$)
		'TConsole.buffer = [str] + TConsole.buffer
		TConsole.in:+[str]
	End Method
	
	Method Flush()
	End Method
End Type

Public

Type TConsole
	
	Function Variable( name:String,v:String )
		vars[name]=v
	End Function
	
	Function Variable( name:String,v:Int )
		vars[name]=String( v )
	End Function
	
	Function Variable( name:String,v:Float )
		vars[name]=String( v )
	End Function
	
	Function Variable:String( name:String )
		Return String( vars[name] )
	End Function
	
	Private

	Global inited:Int
	Global state:Int
	
	Global height:Float, oldHeight:Float
	
	Global vars:THash=New THash
	
	Global names:String[0]
	Global funcs:TFunction[0]

	Global buffer:String[]=["~qhelp~q for display all commands", "console v.1.0"]

	Global in:String[0],addtime:Int
	Global hPos:Int=0

	Global l:String,r:String,help:String

	Global history:String[0],historyPos:Int

	Function Linear:Float( old:Float,v:Float,m:Float )
		Return old+( v-old )*m
	End Function
	
	Function Init()
		If inited Then Return
		inited=True
		
		StandardIOStream=New TConsoleStream
		
		Local name:String,add:Int,i:Int
		
		For Local tid:TTypeId=EachIn TTypeId.EnumTypes()
		For Local func:TFunction=EachIn tid.EnumFunctions()
			
			name=""
			add=False
			
			If func.HasMetaData( "console" )
				name=func.MetaData( "console" )
				add=True
			Else If func.HasMetaData( "cmd" )
				name=func.MetaData( "cmd" )
				add=True
			Else If func.Name().StartsWith( "cmd" ) And func.Name().Length>3
				name=func.Name()[3..]
				add=True
			End If
			
			If Not add Then Continue
			
			If name="" Or name="1" Then name=func.Name()
			name=name.ToLower()
			
			Local ok:Byte=False
			For Local i:Int=0 Until names.Length
				If names[i]=name
					ok=True
					Exit
				End If 
			Next
			If Not ok
				names:+[ name ]
				funcs:+[ func ]
				
				'DebugLog "Console added:"+name+"( "+tid.Name()+" )" 
			End If
			
		Next
		Next
		
	End Function

	Function Update( window:TWindow,canvas:TCanvas )
		
		'Local m:Int[]=window.OnMeasure()
		STimedString.Update()

		If Key.Hit( Key.TILDE )
			state = Not state
			Key.Flush()
			l=""
			r=""
		End If
		
		oldHeight=height
		
		If Not state
			If height > 0
				height:+( ( 0-height )*0.2 ) '*dt
				If height < 1
					height = 0
					Return
				End If
				'Draw( canvas )
			End If
			Return
		End If
		
		If height<>window.GraphicsHeight() Shr 1 'm[1] Shr 1 'App.GraphicsWidth Shr 1
			height:+( ( window.GraphicsHeight() Shr 1-height )*0.2 ) '*dt
		End If
		
		Local char:Int=Key.Char()
		If char Then l:+Chr( char )
		
		If Key.Rep( Key.BACKSPACE )
			If l.Length>0
				l=l[..l.Length-1]
			End If
		End If
		
		help=""
		If l.Length>0 And r.length=0
			For Local vk:String=EachIn vars.Keys()
				If vk.StartsWith( l )
					help=vk+" "
				End If
			Next
			
			If help=""
				For Local i:Int=0 Until names.Length
					If names[i].StartsWith( l.ToLower() )
						help=names[i]+" "
						Exit
					End If
				Next
			End If
		End If

		If Key.Rep( Key.Left )
			If l.Length>0
				r=Chr( l[l.length-1] )+r
				l=l[..l.length-1]
			Else
				
			End If
		End If
			
		If Key.Rep( Key.Right )
			If r.Length>0
				l=l+Chr( r[0] )
				r=r[1..]
			Else
				If help<>"" Then l=help
			End If
		End If
			
		If Key.Rep( Key.PAGE_UP )
			hpos=Min( hpos+1,buffer.Length-1 )
		End If
			
		If Key.Rep( Key.PAGE_DOWN )
			hpos=Max( hpos-1,0 )
		End If
			
		If Key.Hit( Key.ENTER )
			Local cmd:String=( l+r ).Trim().ToLower()
			l=""
			r=""
			If cmd<>"" Then Process( cmd )
		End If
			
		If Key.Rep( Key.UP )
			If history.Length>historyPos
				l=history[historyPos]
				r=""
				historyPos:+1
			End If
		End If
			
		If Key.Rep( Key.DOWN )
			If historyPos
				historyPos:-1
				l=history[historyPos]
				r=""
			End If
		End If
					
		If in.Length>0
			'If (MilliSecs() Mod 100) > 50
			If MilliSecs()>addtime+40
				buffer=[ in[0] ]+buffer
				in=in[1..]
				hpos=0
					
				If buffer.Length>500
					buffer = buffer[..499]
				End If
					
				addtime=MilliSecs()
					
			End If
		End If
		
		Key.Flush()
	End Function
	
	Function process( cmd:String )
		cmd=cmd.Replace( "("," " ).Replace( ")"," " ).Replace( "   "," " ).Replace( "  "," " ).Replace( "~t"," " )
		Local args:String[]=cmd.Split( " " )
		
		Local slug:String=args[0]
		args=args[1..]
		
		If vars[slug]<>Null
			If args.Length=0 Then args=[""]
			
			vars[slug]=args[0]
			
			Print( "Console var '"+slug+"' changet to:"+args[0] )
			
			Return
		End If
		
		For Local i:Int=0 Until names.Length
			If names[i]=slug 'args[0]
				
				Local argTypes:TTypeId[]=funcs[i].ArgTypes()
				args=args[..argTypes.Length]
				funcs[i].Invoke( args )
				
				'If argTypes.Length=0
				'	funcs[i].Invoke( Null )
				'Else
				'	args=args[..argTypes.Length]
				'	funcs[i].Invoke( args )
				'End If
				
				history=[ names[i] ]+history
				historyPos=0
				If history.Length>10 Then history=history[..10]
				Exit
				
			Else If i=names.Length-1
				'cmdNotFound( args )
				Print("Command: <$FFFFAAAA><ha>"+slug+"</ha></$> not found!")
				'in:+["Command: <$FFFFAAAA><ha>"+ args[0] + "</ha></$> not found!"]
			End If
		Next
	End Function

	Function Draw( canvas:TCanvas,tween:Float )
		
		STimedString.Draw( canvas )
		
		If Not state And height=0 Then Return
		
		canvas.PushMatrix()
			
		canvas.Matrix( 1,0,0,1,0,0 )
			
		canvas.Font( Null )
		'c.SetBlend(  )
		
		Local twy:Float=Linear( oldHeight,height,tween )
		
		canvas.Color( 0.0,0.0,0.0 )
		canvas.Alpha( 0.9 )
		canvas.DrawRect( 0,0,canvas.width(),twy ) 'GraphicsWidth(),twy )
		canvas.Alpha(1)
		canvas.Color( .5,.5,.5 )
		canvas.Translate( 0,twy )
		canvas.DrawRect( 0,0,canvas.width(),1 ) 'GraphicsWidth(),1 )
		
		canvas.Translate( 0,-16 )
		If help<>""
			canvas.Color( .5,.5,.5 )
			canvas.DrawText( ">"+help,0,0 )
		End If
		
		canvas.Color( 1,1,1 )
		Local m:String=" "
		If ( MilliSecs() Mod 800 )>400 Then m="|"
		canvas.DrawText( ">"+l+m+r,0,0 )
			
			'Local w%,h%
			'TextSize(buffer, w, h)
			'matrix.translate(0,-h)
			'DrawText(buffer)
			
		Local mat:Float[]
		For Local i:Int=hpos Until buffer.Length
			
			Local w:Int,h:Int
			'matrix.ty:-16
			canvas.Translate( 0,-16 )
			'If matrix.ty + 16 < 0 Then Exit
			mat=canvas.Matrix() ' mat )
			If mat[5]<0 Then Exit
			canvas.DrawText( buffer[i],0,0 )
				
		Next
		
		canvas.PopMatrix()
	End Function
	
	Function cmdHelp()
		Print("<$FF999999>+----------------------------------</$>")
		For Local i:Int=0 Until names.Length
			If names[i]="help" Then Continue
			Print("<$FF999999>|-"+names[i]+"</>")
		Next
		Print("<$FF999999>+----------------------------------</$>")
	End Function
	
	Function cmdVersion()
		Print("+-----------------------------+")
		Print("|     <swear>Command Line Tool</swear>       |")
		Print("|         <$FFFF8888><ha>version 1.0</ha></$>         |")
		Print("+-----------------------------+")
	End Function
	
	Function cmdCls()
		buffer=New String[0]
	End Function 'AddCmd("cls", cmdCls)
	
	Function cmdEnd()
		App.Terminate()
	End Function
End Type
