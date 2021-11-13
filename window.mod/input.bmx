
Public

Rem
	bbdoc: Key modifiers.
End Rem
Type Modifier
	Const Any:Int	=-1
	
	Const None:Int	=0
	Const Shift:Int	=1
	Const Ctrl:Int	=2
	Const Alt:Int	=4
	Const System:Int=8
End Type

Rem
	bbdoc: Keys.
End Rem
Type Key
	Const SPACE:Int		=32
	Const APOSTROPHE:Int=39
	Const COMMA:Int		=44
	Const MINUS:Int		=45
	Const PERIOD:Int	=46
	Const SLASH:Int		=47
	Const SEMICOLON:Int	=59
	Const EQUAL:Int		=61
	
	Const A:Int=65, B:Int=66, C:Int=67, D:Int=68, E:Int=69, F:Int=70, G:Int=71, H:Int=72, I:Int=73
	Const J:Int=74, K:Int=75, L:Int=76, M:Int=77, N:Int=78, O:Int=79, P:Int=80, Q:Int=81, R:Int=82
	Const S:Int=83, T:Int=84, U:Int=85, V:Int=86, W:Int=87, X:Int=88, Y:Int=89, Z:Int=90
	
	Const LEFT_BRACKET:Int	=91
	Const BACKSLASH:Int		=92
	Const RIGHT_BRACKET:Int	=93
	Const TILDE:Int			=96
	
	Const WORLD_1:Int=161, WORLD_2:Int=162

	Const ESCAPE:Int	=256, ESC:Int=ESCAPE
	Const ENTER:Int		=257
	Const TAB:Int		=258
	Const BACKSPACE:Int	=259
	
	Const INS:Int=260, DEL:Int=261
	
	Const Right:Int=262, Left:Int=263, Up:Int=265, ARROW_DOWN:Int=264 'DOWN:Int=264, UP:Int=265
	
	Const PAGE_UP:Int=266, PAGE_DOWN:Int=267, PAGE_DN:Int=PAGE_DOWN
	Const HOME:Int=268, KEND:Int=269
	Const CAPS_LOCK:Int=280, SCROLL_LOCK:Int=281, NUM_LOCK:Int=282
	Const PRINT_SCREEN:Int=283
	Const PAUSE:Int=284
	
	Const F1:Int=290, F2:Int=291, F3:Int=292, F4:Int=293, F5:Int=294, F6:Int=295, F7:Int=296
	Const F8:Int=297, F9:Int=298, F10:Int=299, F11:Int=300, F12:Int=301, F13:Int=302, F14:Int=303
	Const F15:Int=304, F16:Int=305, F17:Int=306, F18:Int=307, F19:Int=308, F20:Int=309, F21:Int=310
	Const F22:Int=311, F23:Int=312, F24:Int=313, F25:Int=314
	
	Const NUM_0:Int=320, NUM_1:Int=321, NUM_2:Int=322, NUM_3:Int=323, NUM_4:Int=324
	Const NUM_5:Int=325, NUM_6:Int=326, NUM_7:Int=327, NUM_8:Int=328, NUM_9:Int=329
	
	Const NUM_DECIMAL:Int	=330
	Const NUM_DIVIDE:Int	=331
	Const NUM_MULTIPLY:Int	=332
	Const NUM_SUBTRACT:Int	=333
	Const NUM_ADD:Int		=334
	Const NUM_ENTER:Int		=335
	Const NUM_EQUAL:Int		=336
	
	Const LEFT_SHIFT:Int=340, LEFT_CONTROL:Int=341, LEFT_ALT:Int=342, LEFT_SUPER:Int=343
	Const RIGHT_SHIFT:Int=344, RIGHT_CONTROL:Int=345, RIGHT_ALT:Int=346, RIGHT_SUPER:Int=347
	
	Const MENU:Int=348
	
	Const LAST:Int=MENU
	Const COUNT:Int=349
	
	Rem
	bbdoc: Check for key hit
	returns: Number of times @key has been hit.
	about:
	The returned value represents the number of the times @key has been hit since the last
	call to #KeyHit with the same @key.

	See the #{key codes} module for a list of valid key codes.
	End Rem
	Function Hit:Int( code:Int,mods:Int=Modifier.Any )
		If code<10 Then code:+48
		Local state:Int=_states[code] And Not _states[code+STATE_OLD]
		_states[code+STATE_OLD]=_states[code]
		If Not state Then Return False
		
		Select mods
		Case Modifier.ANY 	Return True
		Case Modifier.NONE	Return _states[code+STATE_MODS]=0
		Default				Return _states[code+STATE_MODS]&mods
		End Select
	End Function
	
	'hack! - Key.Hit( Key.Down )
	Function Hit:Int( f:Int( code:Int,mods:Int ),mods:Int=Modifier.Any )
		Return Hit( 264,mods )
	End Function
	
	Rem
	bbdoc: Check for key state
	returns: #True if @key is currently down
	about:
	See the #{key codes} module for a list of valid keycodes.
	End Rem
	Function Down:Int( code:Int,mods:Int=Modifier.Any )
		If code<10 Then code:+48
		If Not _states[code] Then Return False
		
		Select mods
		Case Modifier.ANY 	Return True
		Case Modifier.NONE	Return _states[code+STATE_MODS]=0
		Default				Return _states[code+STATE_MODS]&mods
		End Select
	End Function
	
	'Key.Down( Key.Down ) hack =)
	Function Down:Int( f:Int( code:Int,mods:Int ),mods:Int=Modifier.Any )
		Return Down( 264,mods )
	End Function
	
	Rem
	bbdoc: Check for key state
	returns: #True if @key is currently down
	about:
	See the #{key codes} module for a list of valid keycodes.
	End Rem
	Function Rep:Int( code:Int,mods:Int=Modifier.Any )
		Local r:Int=_states[code+STATE_REPEAT] ',0]
		_states[code+STATE_REPEAT]=False
		If Not r Then Return False
		
		Select mods
		Case Modifier.ANY	Return True
		Case Modifier.NONE	Return _states[code+STATE_MODS]=0
		Default				Return _states[code+STATE_MODS]&mods
		End Select
	End Function
	
	'hack!
	Function Rep:Int( f:Int( code:Int,mods:Int ),mods:Int=Modifier.Any )
		Return Rep( 264,mods )
	End Function
	
	Rem
	bbdoc: Get next character
	returns: The character code of the next character.
	about:
	As the user hits keys on the keyboard, BlitzMax records the character codes of these 
	keystrokes into an internal 'character queue'.

	#GetChar removes the next character code from this queue and returns it the application.

	If the character queue is empty, 0 is returned.
	End Rem
	Function Char:Int()
		If _get=_put Then Return 0
		Local n:Int=_queue[_get&255]
		_get:+1
		Return n
	End Function
	
	Rem
	bbdoc: Flush key states and character queue.
	about:
	#FlushKeys resets the state of all keys to 'off', and resets the character queue
	used by #GetChar.
	End Rem
	Function Flush()
		_Get=0
		_Put=0
		MemClear( _states,Size_T( COUNT*4 ) )
	End Function
	
	Rem
	bbdoc: Wait for a key press
	returns: The keycode of the pressed key
	about:
	#WaitKey suspends program execution until a key has been hit. The keycode of this
	key is then returned to the application.

	See the #{key codes} module for a list of valid keycodes.
	End Rem
	Function Wait:Int( chars:Int=False )
		Flush()
		Repeat
			WaitSystem()
			If chars
				Local c:Int=Char()
				If c Then Return c
			Else
				For Local i:Int=1 To LAST
					If Hit( i ) Then Return i
				Next
			End If
		Forever
	End Function
	
	Private
	
	Const STATE_OLD:Int=COUNT
	Const STATE_REPEAT:Int=COUNT*2
	Const STATE_MODS:Int=COUNT*3
	
	Global _states:Byte Ptr=MemAlloc( COUNT*4 ) 'state\oldState\repeat\mods
	Global _get:Int,_put:Int
	Global _queue:Int Ptr=Int Ptr( MemAlloc( 1024 ) )
	
	Function OnKey( windowPtr:Byte Ptr,Key:Int,scancode:Int,action:Int,mods:Int)
		If Key=-1 Then Return
		'DebugLog "key:"+key+",scancode:"+scancode+",action:"+action+",mods:"+mods
		If action<>2 Then _states[Key]=action
		_states[Key+STATE_REPEAT]=action>0 'mods
		_states[Key+STATE_MODS]=mods
	End Function
	
	Function OnChar( windowPtr:Byte Ptr,char:UInt )
		'DebugLog "char:"+char
		If ( _get-_put )<256
			_queue[_put&255]=char
			_put:+1
		End If
	End Function
End Type

Rem
	bbdoc: Mouse.
End Rem
Type Mouse
	Const Left:Int=1
	Const Right:Int=2
	Const Middle:Int=3
	
	Rem
	bbdoc: Check for mouse button click
	returns: Number of times @button has been clicked.
	about:
	The returned value represents the number of the times @button has been clicked since the
	last call to #MouseHit with the same @button.

	@button should be 1 for the left mouse button, 2 for the right mouse button or 3 for the
	middle mouse button. Two further buttons, 4 and 5, are also available for mice that support them.
	End Rem
	Function Hit:Int( code:Int=Left,mods:Int=Modifier.Any )
		code:-1
		Local state:Int=_states[code] And Not _states[code+3]
		_states[code+3]=_states[code]
		If Not state Then Return False
		
		Select mods
		Case Modifier.ANY 	Return True
		Case Modifier.NONE	Return _states[code+6]=0
		Default				Return _states[code+6]&mods
		End Select
	End Function
	
	Rem
	bbdoc: Check for mouse button down state
	returns: #True if @button is currently down
	about:
	@button should be 1 for the left mouse button, 2 for the right mouse button or 3 for the
	middle mouse button. Two further buttons, 4 and 5, are also available for mice that support them.
	End Rem
	Function Down:Int( code:Int=Left,mods:Int=Modifier.Any )
		code:-1
		If Not _States[code] Then Return False
		
		Select mods
		Case Modifier.ANY 	Return True
		Case Modifier.NONE  Return _States[code+6]=0
		Default 			Return _States[code+6]&mods
		End Select
	End Function
	
	Rem
	bbdoc: Get mouse x speed
	returns: Mouse x speed
	End Rem
	Function XSpeed:Float()
		Local speed:Float=_Location[0]-_Location[2]
		_Location[2]=_Location[0]
		Return speed
	End Function
	
	Rem
	bbdoc: Get mouse y speed
	returns: Mouse y speed
	End Rem
	Function YSpeed:Float()
		Local speed:Float=_Location[1]-_Location[3]
		_Location[3]=_Location[1]
		Return speed
	End Function
	
	Rem
	bbdoc: Get mouse z speed
	returns: Mouse z speed
	End Rem
	Function ZSpeed:Float()
		Local speed:Float=_ZSpeed
		_ZSpeed=0
		Return speed
	End Function
	
	Rem
	bbdoc: Move mouse pointer
	about:
	#MoveMouse positions the mouse cursor at a specific location within
	the current window or graphics display.
	End Rem
	Function Location:Float[]()
		Return [ _Location[0],_Location[1] ]
	End Function
	
	Rem
	bbdoc: Move mouse pointer
	about:
	#MoveMouse positions the mouse cursor at a specific location within
	the current window or graphics display.
	End Rem
	Function Location( xy:Float[] )
		If Not App._active Then Return
		bmx_glfw_glfwSetCursorPos( App._active._windowPtr,xy[0],xy[1] )
	End Function
	
	Rem
	bbdoc: Move mouse pointer
	about:
	#MoveMouse positions the mouse cursor at a specific location within
	the current window or graphics display.
	End Rem
	Function Location( x:Float,y:Float )
		If Not App._active Then Return
		bmx_glfw_glfwSetCursorPos( App._active._windowPtr,x,y )
	End Function
	
	Rem
	bbdoc: Get mouse x location
	returns: Mouse x axis location
	about:
	The returned value is relative to the left of the screen.
	End Rem
	Function X:Float()
		Return _Location[0]
	End Function
	
	Rem
	bbdoc: Get mouse x location
	returns: Mouse x axis location
	about:
	The returned value is relative to the left of the screen.
	End Rem
	Function X( v:Float )
		If Not App._active Then Return
		bmx_glfw_glfwSetCursorPos( App._active._windowPtr,v,_Location[1] )
	End Function
	
	Rem
	bbdoc: Get mouse y location
	returns: Mouse y axis location
	about:
	The returned value is relative to the top of the screen.
	End Rem
	Function Y:Float()
		Return _Location[1]
	End Function
	
	Rem
	bbdoc: Get mouse y location
	returns: Mouse y axis location
	about:
	The returned value is relative to the top of the screen.
	End Rem
	Function Y( v:Float )
		If Not App._active Then Return
		bmx_glfw_glfwSetCursorPos( App._active._windowPtr,_Location[0],v )
	End Function
	
	Rem
	bbdoc: Flush mouse button states
	about:
	#FlushMouse resets the state of all mouse buttons to 'off'.
	End Rem
	Function Flush()
		MemClear( _states,Size_T( 9 ) )
		MemClear( _location,Size_T( 16 ) )
		_ZSpeed=0
	End Function
	
	Rem
	bbdoc: Make the mouse pointer invisible
	End Rem
	Function Hide( state:Int=True )
		If state
			If _visible=GLFW_CURSOR_HIDDEN Then Return
			_visible=GLFW_CURSOR_HIDDEN
		Else
			If _visible=GLFW_CURSOR_NORMAL Then Return
			_visible=GLFW_CURSOR_NORMAL
		End If
		UpdateCursor()
	End Function
	
	Rem
	bbdoc: Make the mouse pointer visible
	End Rem
	Function Show( state:Int=True )
		If state
			If _visible=GLFW_CURSOR_NORMAL Then Return
			_visible=GLFW_CURSOR_NORMAL
		Else
			If _visible=GLFW_CURSOR_HIDDEN Then Return
			_visible=GLFW_CURSOR_HIDDEN
		End If
		UpdateCursor()
	End Function
	
	Rem
	bbdoc: Wait for mouse button click
	returns: The clicked button
	about:
	#WaitMouse suspends program execution until a mouse button is clicked.

	#WaitMouse returns 1 if the left mouse button was clicked, 2 if the right mouse button was
	clicked or 3 if the middle mouse button was clicked.
	End Rem
	Function Wait:Int()
		Flush()
		Repeat
			WaitSystem()
			For Local i:Int=Left To Middle
				If Hit( i ) Then Return i
			Next
		Forever
	End Function
	
	Rem
	bbdoc: Wait for mouse button click
	returns: The clicked button
	about:
	#WaitMouse suspends program execution until a mouse button is clicked.

	#WaitMouse returns 1 if the left mouse button was clicked, 2 if the right mouse button was
	clicked or 3 if the middle mouse button was clicked.
	End Rem
	Function Cursor( index:Int )
		If index=_cursor Then Return
		.Cursor.Init()
		For Local i:Int=0 Until App._windows.Length
			bmx_glfw_glfwSetCursor( App._windows[i]._windowPtr,.Cursor.cursors[index]._cursor.cursorPtr )
		Next
		_cursor=index
	End Function
	
	Private
	
	Global _cursor:Int=0
	Global _visible:Int=GLFW_CURSOR_NORMAL
	
	Function UpdateCursor()
		For Local i:Int=0 Until App._windows.Length
			bmx_glfw_glfwSetInputMode( App._windows[i]._windowPtr,GLFW_CURSOR,_visible )
		Next
	End Function
	
	Global _States:Byte Ptr=MemAlloc( 9 ) 'state,old,mods
	Global _Location:Float Ptr=Float Ptr( MemAlloc( 16 ) )
	Global _ZSpeed:Float
	
	Global in:Float[2]
	Global out:Float[2]
	
	Function OnCursorPosition( windowPtr:Byte Ptr,x:Double,y:Double )
		If Not App._active Then Return
		If windowPtr<>App._active._windowPtr Then Return
		
		_Location[2]=_Location[0]
		_Location[3]=_Location[1]
		in[0]=Float( x )
		in[1]=Float( y )
		
		App._active._canvas.TransformCoords( in,out )
		
		_Location[0]=out[0]
		_Location[1]=out[1]
	End Function
	
	Function OnButton( windowPtr:Byte Ptr,button:Int,action:Int,mods:Int )
		If button>2 Then Return
		_States[button]=action
		_States[button+6]=mods '3*2
	End Function
	
	Function OnScroll( windowPtr:Byte Ptr,xOffset:Double,yOffset:Double )
		If Not App._active Then Return
		If windowPtr<>App._active._windowPtr Then Return
		_ZSpeed=Float( yOffset )
	End Function
End Type

Rem
	bbdoc: Cursor class.
End Rem
Type Cursor
	Const Arrow:Int			=0
	Const IBeam:Int			=1
	Const CrossChair:Int	=2
	Const Hand:Int			=3
	Const HResize:Int		=4
	Const VResize:Int		=5
	
	Function Create:Int( pixmap:TPixmap,xhot:Int=0,yhot:Int=0 )
		Init()
		Local c:Cursor=New Cursor
		c._cursor=GLFWCursor.Create( pixmap,xhot,yhot )
		cursors:+[c]
		Return cursors.Length-1
	End Function
	
	Function Load:Int( url:Object,xhot:Int=0,yhot:Int=0 )
		Local pixmap:TPixmap=TPixmap( url )
		If Not pixmap Then pixmap=LoadPixmap( url )
		If Not pixmap Then Return -1
		Return Create( pixmap,xhot,yhot )
	End Function
	
	Private
	
	Function Init()
		If cursors.Length Then Return
		cursors=New Cursor[6]
		For Local i:Int=0 Until 6
			cursors[i]=New Cursor
		Next
		cursors[0]._cursor=New GLFWcursor( bmx_glfw_glfwCreateStandardCursor( $00036001 ),False )
		cursors[1]._cursor=New GLFWcursor( bmx_glfw_glfwCreateStandardCursor( $00036002 ),False )
		cursors[2]._cursor=New GLFWcursor( bmx_glfw_glfwCreateStandardCursor( $00036003 ),False )
		cursors[3]._cursor=New GLFWcursor( bmx_glfw_glfwCreateStandardCursor( $00036004 ),False )
		cursors[4]._cursor=New GLFWcursor( bmx_glfw_glfwCreateStandardCursor( $00036005 ),False )
		cursors[5]._cursor=New GLFWcursor( bmx_glfw_glfwCreateStandardCursor( $00036006 ),False )
	End Function
	
	Field _cursor:GLFWCursor
	
	Global cursors:Cursor[0]
End Type

Type Hat
	Const CENTERED:Int=0
	Const UP:Int=1
	Const Right:Int=2
	Const DOWN:Int=4
	Const Left:Int=8
	
	Const RIGHT_UP:Int=Right|UP
	Const RIGHT_DOWN:Int=Right|DOWN
	Const LEFT_UP:Int=Left|UP
	Const LEFT_DOWN:Int=Left|DOWN
End Type
 
Rem
	bbdoc: Joystick type.
End Rem
Type TJoystick
	
	Rem
	bbdoc: Available buttons (on/off controls) on a joystick.
	returns: A bitfield representing which buttons are present.
	End Rem
	Function NumJoysticks:Int()
		For Local id:Int=0 Until GLFW_JOYSTICK_LAST
			If Not bmx_glfw_glfwJoystickPresent( id ) Then Return id
		Next
	End Function
	
	Rem
	bbdoc: Create new joystick.
	End Rem
	Method New( id:Int )
		Self.id=id
		use:+1
	End Method
	
	Method New()
		use:+1
	End Method
	
	Method Delete()
		use:-1
	End Method
	
	Rem
	bbdoc: This function returns the name of the specified joystick.
	about: The returned string is allocated and freed by GLFW. You should not free it yourself.

	If the specified joystick is not present this function will return #Null but will not generate an error.
	This can be used instead of first calling #JoystickPresent.
	End Rem
	Method ToString:String()
		Local n:Byte Ptr=bmx_glfw_glfwGetJoystickName( id )
		If n Then Return String.FromUTF8String( n )
	End Method
	
	Rem
	bbdoc: This function returns the SDL compatible GUID, as a hexadecimal #String, of the specified joystick.
	about: The GUID is what connects a joystick to a gamepad mapping. A connected joystick will always have a GUID even if there is no
	gamepad mapping assigned to it.

	If the specified joystick is not present this function will return #Null but will not generate an error.
	This can be used instead of first calling #JoystickPresent.

	The GUID uses the format introduced in SDL 2.0.5. This GUID tries to uniquely identify the make and model of a joystick
	but does not identify a specific unit, e.g. all wired Xbox 360 controllers will have the same GUID on that platform.
	The GUID for a unit may vary between platforms depending on what hardware information the platform specific APIs provide.
	End Rem
	Method GUID:String()
		Local g:Byte Ptr=bmx_glfw_glfwGetJoystickGUID( id )
		If g Then Return String.FromUTF8String( g )
	End Method
	
	Rem
	bbdoc: Connection state.
	End Rem
	Method Attached:Int()
		Return bmx_glfw_glfwJoystickPresent( id )
	End Method
	
	Rem
	bbdoc: Available buttons (on/off controls) on a joystick.
	returns: A bitfield representing which buttons are present.
	End Rem
	Method NumAxes:Int()
		Local count:Int
		bmx_glfw_glfwGetJoystickAxes( id,count )
		Return count
	End Method
	
	Rem
	bbdoc: Available buttons (on/off controls) on a joystick.
	returns: A bitfield representing which buttons are present.
	End Rem
	Method NumButtons:Int()
		Local count:Int
		bmx_glfw_glfwGetJoystickButtons( id,count )
		Return count
	End Method
	
	Rem
	bbdoc: Available buttons (on/off controls) on a joystick.
	returns: A bitfield representing which buttons are present.
	End Rem
	Method NumHats:Int()
		Local count:Int
		bmx_glfw_glfwGetJoystickHats( id,count )
		Return count
	End Method
	
	Rem
	bbdoc: Joystick axis states
	End Rem
	Method Axe:Float( num:Int )
		Local count:Int
		Local states:Float Ptr=bmx_glfw_glfwGetJoystickAxes( id,count )
		If num>=count Then Return 0.0
		Local res:Float=states[num]
		If res<0.1 And res>-0.1 Then res=0
		Return res
	End Method
	
	Rem
	bbdoc: Test the status of a joystick button.
	returns: True if the button is pressed.
	End Rem
	Method Down:Int( button:Int )
		Return states[id Shl 4+button]
	End Method
	
	Rem
	bbdoc: Check for a joystick button press
	returns: Number of times @button has been hit.
	about:
	The returned value represents the number of the times @button has been hit since 
	the last call to #JoyHit with the same specified @button.
	End Rem
	Method Hit:Int( button:Int )
		Local i:Int=id Shl 4+button
		Local state:Int=states[i] And Not oldStates[i]
		oldStates[i]=states[i]
		Return state
	End Method
	
	Rem
	bbdoc:.
	End Rem
	Method Hat:Int( num:Int )
		Local count:Int
		Local states:Byte Ptr=bmx_glfw_glfwGetJoystickHats( id,count )
		If num>=count Then Return 0
		Return states[num]
	End Method
	
	Rem
	bbdoc: Flush joystick button states.
	End Rem
	Method Flush()
		MemClear( states,Size_T( 256 ) )
		MemClear( oldStates,Size_T( 256 ) )
	End Method
	
	Private
	
	Field id:Int
	
	Global use:Int
	
	Global states:Byte Ptr=MemAlloc( 256 )
	Global oldStates:Byte Ptr=MemAlloc( 256 )
	
	Function Update()
		If Not use Then Return
		
		Local count:Int
		For Local id:Int=0 Until GLFW_JOYSTICK_LAST
			If Not bmx_glfw_glfwJoystickPresent( id ) Then Return
			Local s:Byte Ptr=bmx_glfw_glfwGetJoystickButtons( id,count )
			count=Min( count,16 )
			For Local button:Int=0 Until count
				Local i:Int=id Shl 4+button
				states[i]=s[button]
				If Not s[button] Then oldStates[i]=False 'oldStates[id,button]=False
			Next
		Next
	End Function
	
	Function CallBack( id:Int,event:Int )
		If event=262145
			Local s:String
			Local n:Byte Ptr=bmx_glfw_glfwGetJoystickName( id )
			If n Then s=String.FromUTF8String( n )
			Print( s+" connected." )
		ElseIf event=262146
			Print( "joystick disconnected." )
		End If
	End Function
End Type

bmx_glfw_glfwSetJoystickCallback( TJoystick.CallBack )
