'
' BlitzMax port, 2015 Bruce A Henderson
' 
' Copyright (c) 2015 Mark Sibly
' 
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
' 
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
' 
' 1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgement in the product documentation would be
'    appreciated but is not required.
' 2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
' 3. This notice may not be removed or altered from any source distribution.
' 
SuperStrict

Import GLFW.GLFW
Import GLFW.OpenGL

'Import BRL.Bank
'Import BRL.Map
Import BRL.LinkedList
Import BRL.RAMStream
Import BRL.PNGLoader 'pixmap
Import BRL.FileSystem
Import BRL.RandomDefault
'Import PUB.FreeType
Import MinGW.Hash

Import "color.bmx"
Import "math3d.bmx"
Import "glutil.bmx"
Import "glslparser.bmx"
'Import "maps.bmx"

Include "shader.bmx"
Include "texture.bmx"
Include "material.bmx"
Include "image.bmx"
Include "font.bmx"

Include "hgefont.bmx"
'Include "fretype.bmx"
Include "manager.bmx"

Incbin "data/mojo2_font.png"
Incbin "data/mojo2_program.glsl"
Incbin "data/mojo2_fastshader.glsl"
Incbin "data/mojo2_bumpshader.glsl"
Incbin "data/mojo2_matteshader.glsl"
Incbin "data/mojo2_shadowshader.glsl"
Incbin "data/mojo2_lightmapshader.glsl"

Public

Function GenVAO:Int()
	Mojo.Init()
	
	Local vao:Int,f:Int=0 ',vbo:Int,ibo:Int
	
	glGenVertexArrays( 1,Varptr vao )
	glBindVertexArray( vao )
	
	glBindBuffer( GL_ARRAY_BUFFER,Mojo.rs_vbo )
	glBufferData( GL_ARRAY_BUFFER,PRIM_VBO_SIZE,Null,VBO_USAGE )
	
	glEnableVertexAttribArray( 0 )
	glVertexAttribPointer( 0,2,GL_FLOAT,False,BYTES_PER_VERTEX,Byte Ptr( 0 ) )
	
	glEnableVertexAttribArray( 1 )
	glVertexAttribPointer( 1,2,GL_FLOAT,False,BYTES_PER_VERTEX,Byte Ptr( 8 ) )
	
	glEnableVertexAttribArray( 2 )
	glVertexAttribPointer( 2,2,GL_FLOAT,False,BYTES_PER_VERTEX,Byte Ptr( 16 ) )
	
	glEnableVertexAttribArray( 3 )
	glVertexAttribPointer( 3,4,GL_UNSIGNED_BYTE,True,BYTES_PER_VERTEX,Byte Ptr( 24 ) )
	
	glBindBuffer( GL_ELEMENT_ARRAY_BUFFER,Mojo.rs_ibo )

	Mojo.rs_vao=vao
	
	Return vao
End Function

Function DelVAO( vao:Int )
	glDeleteVertexArrays( 1,Varptr vao )
End Function

Function SetVAO( vao:Int )
	If Mojo.rs_vao=vao Then Return
	glBindVertexArray( vao )
	Mojo.rs_vao=vao
End Function

Private

Type Mojo

	Global mainShader:String

	Global _fastShader:TShader
	Global _bumpShader:TShader
	Global _matteShader:TShader
	Global _shadowShader:TShader
	Global _lightMapShader:TShader

	Global defaultFont:TFont
	Global _defaultShader:TShader

	Global freeOps:TDrawOpStack=New TDrawOpStack
	Global nullOp:TDrawOp=New TDrawOp

	Global defaultFbo:Int

	Global tmpMat2d:Float[6]
	Global tmpMat3d:Float[16]
	Global tmpMat3d2:Float[16]

	Global flipYMatrix:Float[]=Mat4New()

	'shader params
	Global rs_projMatrix:Float[]=Mat4New()
	Global rs_modelViewMatrix:Float[]=Mat4New()
	Global rs_modelViewProjMatrix:Float[]=Mat4New()
	Global rs_clipPosScale:Float[]=[1.0,1.0,1.0,1.0]
	Global rs_globalColor:Float[]=[1.0,1.0,1.0,1.0]
	Global rs_numLights:Int
	Global rs_fogColor:SColorF=SColorF.None 'Float[]=[0.0,0.0,0.0,0.0]
	Global rs_ambientLight:SColorF=SColorF.Black 'Float[]=[0.0,0.0,0.0,1.0]
	Global rs_lightColors:SColorF[MAX_LIGHTS] 'Float[MAX_LIGHTS*4]
	Global rs_lightVectors:Float[MAX_LIGHTS*4]
	Global rs_shadowTexture:TTexture
	Global rs_program:SGLProgram
	Global rs_material:TMaterial
	Global rs_blend:Int=-1
	Global rs_vbo:Int, rs_ibo:Int, rs_vao:Int
	
	Global inited:Int

	Function Init()
		If inited Then Return
		inited=True

		gladLoadGL( glfwGetProcAddress )
		
		glGetIntegerv( GL_FRAMEBUFFER_BINDING,Varptr defaultFbo )
		
		mainShader=LoadString( "incbin::data/mojo2_program.glsl" )
		
		_fastShader=New TShader( LoadString( "incbin::data/mojo2_fastshader.glsl" ) )
		_bumpShader=New TBumpShader( LoadString( "incbin::data/mojo2_bumpshader.glsl" ) )
		_matteShader=New TMatteShader( LoadString( "incbin::data/mojo2_matteshader.glsl" ) )
		_shadowShader=New TShader( LoadString( "incbin::data/mojo2_shadowshader.glsl" ) )
		_lightMapShader=New TShader( LoadString( "incbin::data/mojo2_lightmapshader.glsl" ) )
		_defaultShader=_bumpShader

		defaultFont=TFont.Load( "incbin::data/mojo2_font.png",32,96,True )'9,13,1,0,7,13,32,96 )
		If Not defaultFont Throw "Can't load default font"
		
		flipYMatrix[5]=-1
	
		'VBO
		glGenBuffers( 1,Varptr Mojo.rs_vbo )
		
		'IBO
		glGenBuffers( 1,Varptr Mojo.rs_ibo )
		glBindBuffer( GL_ELEMENT_ARRAY_BUFFER,Mojo.rs_ibo )
		
		Local idxs:Byte[MAX_QUAD_INDICES*4*2]
		
		For Local j:Size_T = 0 Until 4
			Local k:Size_T = j*MAX_QUAD_INDICES*2
			For Local i:Size_T = 0 Until MAX_QUADS
				Short Ptr( Varptr idxs[i*12+k+0] )[0]=Short( i*4+j+0 )
				Short Ptr( Varptr idxs[i*12+k+2] )[0]=Short( i*4+j+1 )
				Short Ptr( Varptr idxs[i*12+k+4] )[0]=Short( i*4+j+2 )
				Short Ptr( Varptr idxs[i*12+k+6] )[0]=Short( i*4+j+0 )
				Short Ptr( Varptr idxs[i*12+k+8] )[0]=Short( i*4+j+2 )
				Short Ptr( Varptr idxs[i*12+k+10] )[0]=Short( i*4+j+3 )
			Next
		Next
		glBufferData( GL_ELEMENT_ARRAY_BUFFER,idxs.Length,idxs,GL_STATIC_DRAW )
	End Function
End Type

Const VBO_USAGE:Int=GL_STREAM_DRAW
Const VBO_ORPHANING_ENABLED:Int=False

Const MAX_LIGHTS:Int=4
Const BYTES_PER_VERTEX:Int=28

'can really be anything <64K (due to 16bit indices) but this keeps total 
'VBO size<64K, And making it bigger doesn't seem to improve performance much.
Const MAX_VERTICES:Int=65536/BYTES_PER_VERTEX	

Const MAX_QUADS:Int=MAX_VERTICES/4
Const MAX_QUAD_INDICES:Int=MAX_QUADS*6
Const PRIM_VBO_SIZE:Int=MAX_VERTICES*BYTES_PER_VERTEX

Function IsPow2:Int( sz:Int )
	Return ( sz&( sz-1 ) )=0
End Function

Struct SLightData
	Field kind:Int=0
	'Field color:Float[]=[1.0,1.0,1.0,1.0]
	Field color:SColorF
	Field position:Float[]=[0.0,0.0,-10.0]
	Field Range:Float=10
	'
	Field vector:Float[]=[0.0,0.0,-10.0,1.0]
	Field tvector:Float[4]
End Struct

Public

Type TRefCounted Abstract
	Method Retain()
		If _refs<=0 Throw "Internal error"
		_refs:+1
	End Method

	Method Free()
		If _refs<=0 Throw "Internal error"
		_refs:-1
		If _refs Return
		_refs=-1
		OnDestroy()
	End Method
	
	Protected
	
	Method OnDestroy() Abstract
	
	Private
	
	Field _refs:Int=1
End Type

'***** ShaderCaster *****

Rem
bbdoc: The ShadowCaster class provides support for simple 2d shadow rendering.
about: Shadow casters are used by #Renderer objects when rendering layers. To render shadows, you will need to add
shadow casters to the drawlists returned by ILayer.OnRenderLayer.
A shadow caster can either be added to a drawlist using [[DrawList.AddShadowCaster]], or attached to images using [[Image.SetShadowCaster]]. Shadow casters attached to images are automatically added to drawlists when an image is drawn.
A shadow caster contains a set of 2d vertices which describe the geometric shape of the object that casts a shadow. The vertices should describe a convex polygon.
End Rem
Type TShadowCaster
	
	Method New()
	End Method
	
	Method New( verts:Float[],kind:Int=-1 )
		If verts Then
			_verts=verts
		End If
		If kind >= 0 Then
			_kind=kind
		End If
	End Method
	
	Rem
	bbdoc: Set shadow caster vertices.
	end rem
	Method Vertices( vertices:Float[] )
		_verts=vertices
	End Method
	
	Rem
	bbdoc: Get shadow caster vertices.
	end rem
	Method Vertices:Float[]()
		Return _verts
	End Method

	Method Kind( kind:Int )
		_kind=kind
	End Method
	
	Method Kind:Int()
		Return _kind
	End Method
	
	Private
	
	Field _verts:Float[]
	Field _kind:Int
End Type

'***** DrawList *****

Private

Type TDrawOp
	Field material:TMaterial
	Field blend:Int
	Field order:Int
	Field count:Int
End Type

Public

Type TBlendMode
	Const Opaque:Int=0
	Const Alpha:Int=1
	Const Additive:Int=2
	Const Multiply:Int=3
	Const Multiply2:Int=4
	Const Overlay:Int=5
End Type

Rem
bbdoc: A drawlist contains drawing state and a sequence of 2d drawing operations.
about:
You add drawing operations to a drawlist using any of the Draw methods. When a drawing operation is added, the current drawing state is captured by the drawing operation. Further changes to the drawing state will not affect drawing operations already in the drawlist.
A [[Canvas]] extends [[DrawList]], and can be used to draw directly to the app window or an image. A drawlist can also be rendered to a canvas using [[Canvas.RenderDrawList]].
A drawlist's drawing state consists of:
| @Drawing state			| @Description
| Current color			| [[SetColor]]
| Current 2d matrix		| [[Translate]], [[Rotate]], [[Scale]], [[PushMatrix]], [[PopMatrix]]
| Current blend mode		| [[SetBlendMode]]
| Current font			| [[DrawText]]
End Rem
Type TDrawList

	Method New()
		Mojo.Init()
		DefaultMaterial( Mojo._fastShader.DefaultMaterial() )
	End Method
	
	Method BlendMode( blend:Int )
		_blend=blend
	End Method
	
	Method BlendMode:Int()
		Return _blend
	End Method
	
	Method Color( r:Float,g:Float,b:Float,a:Float=-1 )
		If a=-1 Then a=_color.a
		Color( New SColorF( r,g,b,a ) )
		'If a=-1 Then a=_color[3]
		'_color=New SColor( r,g,b,a )
		'_color[0]=r
		'_color[1]=g
		'_color[2]=b
		'If a>=0 Then _color[3]=a
		'Local _alpha:Float=_color.a*255
		'_pmcolor=Int(_alpha) Shl 24 | Int(_color[2]*_alpha) Shl 16 | Int(_color[1]*_alpha) Shl 8 | Int(_color[0]*_alpha)
	End Method
	
	Method Color( rgba:Int )
		Local p:Byte Ptr=Byte Ptr Varptr rgba
		Color( Float( p[3] )/255.0,Float( p[2] )/255.0,Float( p[1] )/255.0,Float( p[0] )/255.0 )
	End Method
	
	Method Color( color:SColorF )
		_color=color
		Local _alpha:Float=_color.a*255
		_pmcolor=Int(_alpha) Shl 24 | Int(_color.b*_alpha) Shl 16 | Int(_color.g*_alpha) Shl 8 | Int(_color.r*_alpha)
	End Method
	
	Method Color:SColorF()
		Return _color
	End Method
	
	'Method Color( rgba:Float[] )
	'	Local r:Float=rgba[0]
	'	Local g:Float=rgba[1]
	'	Local b:Float=rgba[2]
	'	Local a:Float=-1
	'	If rgba.Length>3 Then a=rgba[3]
	'	Color( r,g,b,a ) 
	'End Method
	
	'Method Color:Float[]()
	'	For Local i:Int=0 Until 4
	'		_colRet[i]=_color[i]
	'	Next
	'	Return _colRet
	'End Method
	
	Method Alpha( a:Float )
		Color( New SColorF( _color.r,_color.g,_color.b,a ) )
	End Method
	
	Method Alpha:Float()
		Return _color.a
	End Method
	
	Rem
	bbdoc: Sets the current 2d matrix to the identity matrix.
	about: Same as Matrix( 1,0,0,1,0,0 ).
	End Rem
	Method ResetMatrix()
		_ix=1;_iy=0;_jx=0;_jy=1;_tx=0;_ty=0
	End Method
	
	Rem
	bbdoc: Sets the current 2d matrix to the given matrix.
	end rem
	Method Matrix( ix:Float,iy:Float,jx:Float,jy:Float,tx:Float,ty:Float )
		_ix=ix;_iy=iy;_jx=jx;_jy=jy;_tx=tx;_ty=ty
	End Method
	
	Rem
	bbdoc: Sets the current 2d matrix to the given matrix.
	end rem
	Method Matrix( matrix:Float[] )
		Self.Matrix( matrix[0],matrix[1],matrix[2],matrix[3],matrix[4],matrix[5] )
	End Method
	
	Rem
	bbdoc: Gets the current 2d matrix.
	End Rem
	Method Matrix:Float[]()
		_matRet[0]=_ix;_matRet[1]=_iy;_matRet[2]=_jx
		_matRet[3]=_jy;_matRet[4]=_tx;_matRet[5]=_ty
		Return _matRet
	End Method
	
	Rem
	bbdoc: Multiplies the current 2d matrix by the given matrix.
	end rem
	Method Transform( ix:Float,iy:Float,jx:Float,jy:Float,tx:Float,ty:Float )
		Local ix2:Float=ix*_ix+iy*_jx
		Local iy2:Float=ix*_iy+iy*_jy
		Local jx2:Float=jx*_ix+jy*_jx
		Local jy2:Float=jx*_iy+jy*_jy
		Local tx2:Float=tx*_ix+ty*_jx+_tx
		Local ty2:Float=tx*_iy+ty*_jy+_ty
		Matrix( ix2,iy2,jx2,jy2,tx2,ty2 )
	End Method
	
	Method Transform( matrix:Float[] )
		Transform( matrix[0],matrix[1],matrix[2],matrix[3],matrix[4],matrix[5] )
	End Method

	Rem
	bbdoc: Translates the current 2d matrix.
	end rem
	Method Translate( tx:Float,ty:Float )
		Transform( 1,0,0,1,tx,ty )
	End Method
	
	Rem
	bbdoc: Rotates the current 2d matrix.
	end rem
	Method Rotate( rz:Float )
		Transform( Cosinus( rz ),-Sinus( rz ),Sinus( rz ),Cosinus( rz ),0,0 )
	End Method
	
	Rem
	bbdoc: Scales the current 2d matrix.
	end rem
	Method Scale( sx:Float,sy:Float )
		Transform( sx,0,0,sy,0,0 )
	End Method
	
	Rem
	bbdoc: Translates and rotates (in that order) the current 2d matrix.
	end rem
	Method TranslateRotate( tx:Float,ty:Float,rz:Float )
		Transform( Cosinus( rz ),-Sinus( rz ),Sinus( rz ),Cosinus( rz ),tx,ty )
	End Method
	
	Rem
	bbdoc: Rotates and scales (in that order) the current 2d matrix.
	end rem
	Method RotateScale( rz:Float,sx:Float,sy:Float )
		Transform( Cosinus( rz )*sx,-Sinus( rz )*sy,Sinus( rz )*sx,Cosinus( rz )*sy,0,0 )
	End Method
	
	Method TranslateScale( tx:Float,ty:Float,sx:Float,sy:Float )
		Transform( sx,0,0,sy,tx,ty )
	End Method
	
	Rem
	bbdoc: Translates, rotates and scales (in that order) the current 2d matrix.
	end rem
	Method TranslateRotateScale( tx:Float,ty:Float,rz:Float,sx:Float,sy:Float )
		Transform( Cosinus( rz )*sx,-Sinus( rz )*sy,Sinus( rz )*sx,Cosinus( rz )*sy,tx,ty )
	End Method
	
	Rem
	bbdoc: Sets the maximum number of 2d matrices that can be pushed onto the matrix stack using @PushMatrix.
	end rem
	Method MatrixStackCapacity( capacity:Int )
		_matStack = _matStack[..capacity*6]
		_matSp=0
	End Method
	
	Rem
	bbdoc: Gets the maximum number of 2d matrices that can be pushed onto the matrix stack using @PushMatrix.
	end rem
	Method MatrixStackCapacity:Int()
		Return _matStack.Length/6
	End Method
	
	Rem
	bbdoc: Pushes the current 2d matrix on the 2d matrix stack.
	end rem
	Method PushMatrix()
		_matStack[_matSp+0]=_ix;_matStack[_matSp+1]=_iy
		_matStack[_matSp+2]=_jx;_matStack[_matSp+3]=_jy
		_matStack[_matSp+4]=_tx;_matStack[_matSp+5]=_ty
		_matSp:+6
		If _matSp>=_matStack.Length Then _matSp:-_matStack.Length
	End Method
	
	Rem
	bbdoc: Pops the current 2d matrix from the 2d matrix stack.
	end rem
	Method PopMatrix()
		_matSp:-6
		If _matSp<0 Then _matSp:+_matStack.Length
		_ix=_matStack[_matSp+0];_iy=_matStack[_matSp+1]
		_jx=_matStack[_matSp+2];_jy=_matStack[_matSp+3]
		_tx=_matStack[_matSp+4];_ty=_matStack[_matSp+5]
	End Method
	
	Rem
	bbdoc: Sets current font for use with #DrawText.
	about: 	If @font is null, a default font is used.
	end rem
	Method Font( font:TFont )
		If Not font Then font=Mojo.defaultFont
		_font=font
	End Method
	
	Rem
	bbdoc: Gets the current font.
	end rem
	Method Font:TFont()
		If _font=Mojo.defaultFont Then Return Null
		Return _font
	End Method
	
	Rem
	bbdoc: Sets the default material used for drawing operations that use a null material.
	end rem
	Method DefaultMaterial( material:TMaterial )
		_defaultMaterial=material
	End Method
	
	Rem
	bbdoc: Returns the current default material.
	end rem
	Method DefaultMaterial:TMaterial()
		Return _defaultMaterial
	End Method
	
	Rem
	bbdoc: Draws a point at @x0,@y0.
	about: If @material is null, the current default material is used.
	end rem
	Method DrawPoint( x0:Float,y0:Float,material:TMaterial=Null,s0:Float=0,t0:Float=0 )
		BeginPrim( material,1 )
		PrimVert( x0+0.5,y0+0.5,s0,t0 )
	End Method
	
	Rem
	bbdoc: Draws a line from @x0,@y0 to @x1,@y1.
	about: If @material is null, the current default material is used.
	end rem
	Method DrawLine( x0:Float,y0:Float,x1:Float,y1:Float,material:TMaterial=Null,s0:Float=0,t0:Float=0,s1:Float=1,t1:Float=0 )
		BeginPrim( material,2 )
		PrimVert( x0+0.5,y0+0.5,s0,t0 )
		PrimVert( x1+0.5,y1+0.5,s1,t1 )
	End Method
	
	Rem
	bbdoc: Draw a triangle.
	about: If @material is null, the current default material is used.
	End Rem
	Method DrawTriangle( x0:Float,y0:Float,x1:Float,y1:Float,x2:Float,y2:Float,material:TMaterial=Null,s0:Float=.5,t0:Float=0,s1:Float=1,t1:Float=1,s2:Float=0,t2:Float=1 )
		BeginPrim( material,3 )
		PrimVert( x0,y0,s0,t0 )
		PrimVert( x1,y1,s1,t1 )
		PrimVert( x2,y2,s2,t2 )
	End Method
	
	Rem
	bbdoc: Draw a quad.
	about: If @material is null, the current default material is used.
	end rem
	Method DrawQuad( x0:Float,y0:Float,x1:Float,y1:Float,x2:Float,y2:Float,x3:Float,y3:Float,material:TMaterial=Null,s0:Float=.5,t0:Float=0,s1:Float=1,t1:Float=1,s2:Float=0,t2:Float=1 )
		BeginPrim( material,4 )
		PrimVert( x0,y0,s0,t0 )
		PrimVert( x1,y1,s1,t1 )
		PrimVert( x2,y2,s2,t2 )
		PrimVert( x3,y3,s2,t2 )
	End Method
	
	Rem
	bbdoc: Draw an oval in the given rectangle.
	about: If @material is null, the current default material is used.
	end rem
	Method DrawOval( x:Float,y:Float,width:Float,height:Float,material:TMaterial=Null )
		Local xr:Float=width/2.0
		Local yr:Float=height/2.0
		
		Local dx_x:Float=xr*_ix
		Local dx_y:Float=xr*_iy
		Local dy_x:Float=yr*_jx
		Local dy_y:Float=yr*_jy
		Local dx:Float=Sqr( dx_x*dx_x+dx_y*dx_y )
		Local dy:Float=Sqr( dy_x*dy_x+dy_y*dy_y )

		Local n:Int=Int( dx+dy )
		If n<12 
			n=12 
		Else If n>MAX_VERTICES
			n=MAX_VERTICES
		Else
			n:&~3
		EndIf
		
		Local x0:Float=x+xr
		Local y0:Float=y+yr
		
		BeginPrim( material,n )
		
		For Local i:Int=0 Until n
			Local th:Float=i*360.0/n
			Local px:Float=x0+Cos( th ) * xr
			Local py:Float=y0+Sin( th ) * yr
			PrimVert( px,py,0,0 )
		Next
	End Method
	
	Rem
	bbdoc: Draw an ellipse at @x, @y with radii @xRadius, @yRadius.
	about: If @material is null, the current default material is used.
	end rem
	Method DrawEllipse( x:Float,y:Float,xr:Float,yr:Float,material:TMaterial=Null )
		DrawOval( x-xr,y-yr,xr*2,yr*2,material )
	End Method
	
	Rem
	bbdoc: Draw a circle at @x, @y with radius @radius.
	about: If @material is null, the current default material is used.
	end rem
	Method DrawCircle( x:Float,y:Float,r:Float,material:TMaterial=Null )
		DrawOval( x-r,y-r,r*2,r*2,material )
	End Method
	
	Method DrawPoly( vertices:Float[],material:TMaterial=Null )
		Local n:Int=vertices.Length/2
		If n<3 Or n>MAX_VERTICES Then Return
	
		BeginPrim( material,n )

		For Local i:Int=0 Until n
			PrimVert( vertices[i*2],vertices[i*2+1],0,0 )
		Next
	End Method
	
	Rem
	bbdoc: Draw a batch of primtives.
	about:
	@order is the number of vertices for each primitive, eg: 1 for points, 2 for lines, 3 for triangles etc.
	@count is the number of primitives to draw.
	The @vertices array contains x,y vertex data, and must be at least @count \* @order \* 2 long.
	If @material is null, the current default material is used.
	end rem
	Method DrawPrimitives( order:Int,count:Int,vertices:Float[],material:TMaterial=Null )
		BeginPrim( material,order,count )
		Local p:Int=0
		For Local i:Int=0 Until count
			For Local j:Int=0 Until order
				PrimVert( vertices[p],vertices[p+1],0,0 )
				p:+2
			Next
		Next
	End Method
	
	Rem
	bbdoc: Draw a batch of primtives.
	about: 
	@order is the number of vertices for each primitive, eg: 1 for points, 2 for lines, 3 for triangles etc.
	@count is the number of primitives to draw.
	The @vertices array contains x,y vertex data, and must be at least @count \* @order \* 2 long.
	The @texcoords array contains s,t texture coordinate data, and must be at least @count \* @order \* 2 long.
	If @material is null, the current default material is used.
	end rem
	Method DrawPrimitives( order:Int,count:Int,vertices:Float[],texcoords:Float[],material:TMaterial=Null )
		BeginPrim( material,order,count )
		Local p:Int=0
		For Local i:Int=0 Until count
			For Local j:Int=0 Until order
				PrimVert( vertices[p],vertices[p+1],texcoords[p],texcoords[p+1] )
				p:+2
			Next
		Next
	End Method
	
	Rem
	bbdoc: Draw a batch of indexed primtives.
	about:
	@order is the number of vertices for each primitive, eg: 1 for points, 2 for lines, 3 for triangles etc.
	@count is the number of primitives to draw.
	The @vertices array contains x,y vertex data.
	The @indices array contains vertex indices, and must be at least @count \* @order long.
	If @material is null, the current default material is used.
	end rem
	Method DrawIndexedPrimitives( order:Int,count:Int,vertices:Float[],indices:Int[],material:TMaterial=Null )
		BeginPrim( material,order,count )
		Local p:Int=0
		For Local i:Int=0 Until count
			For Local j:Int=0 Until order
				Local k:Int=indices[p+j]*2
				PrimVert( vertices[k],vertices[k+1],0,0 )
			Next
			p:+order
		Next
	End Method
	
	Method DrawIndexedPrimitives( order:Int,count:Int,vertices:Float[],texcoords:Float[],indices:Int[],material:TMaterial=Null )
		BeginPrim( material,order,count )
		Local p:Int=0
		For Local i:Int=0 Until count
			For Local j:Int=0 Until order
				Local k:Int=indices[p+j]*2
				PrimVert( vertices[k],vertices[k+1],texcoords[k],texcoords[k+1] )
			Next
			p:+order
		Next
	End Method
	
	Rem
	bbdoc: Draws a rect from @x,@y to @x+@width,@y+@height.
	about: If @material is null, the current default material is used.
	end rem
	Method DrawRect( x0:Float,y0:Float,width:Float,height:Float,material:TMaterial=Null,s0:Float=0,t0:Float=0,s1:Float=1,t1:Float=1 )
		Local x1:Float=x0+width
		Local y1:Float=y0+height
		BeginPrim( material,4 )
		PrimVert( x0,y0,s0,t0 )
		PrimVert( x1,y0,s1,t0 )
		PrimVert( x1,y1,s1,t1 )
		PrimVert( x0,y1,s0,t1 )
	End Method
	
	Rem
	bbdoc: Draws a rect from @x,@y to @x+@width,@y+@height filled with @image.
	about: The image's handle is ignored.
	end rem
	Method DrawRect( x0:Float,y0:Float,width:Float,height:Float,image:TImage )
		DrawRect( x0,y0,width,height,image._material,image._s0,image._t0,image._s1,image._t1 )
	End Method
	
	Rem
	bbdoc: Draws a rect at @x,@y filled with the given subrect of @image.
	about: The image's handle is ignored.
	end rem
	Method DrawRect( x:Float,y:Float,image:TImage,sourceX:Int,sourceY:Int,sourceWidth:Int,sourceHeight:Int )
		DrawRect( x,y,sourceWidth,sourceHeight,image,sourceX,sourceY,sourceWidth,sourceHeight )
	End Method

	Rem
	bbdoc: Draws a rect from @x,@y to @x+@width,@y+@height filled with the given subrect of @image.
	about: The image's handle is ignored.
	end rem
	Method DrawRect( x0:Float,y0:Float,width:Float,height:Float,image:TImage,sourceX:Int,sourceY:Int,sourceWidth:Int,sourceHeight:Int )
		Local material:TMaterial=image._material
		Local s0:Float=Float(image._x+sourceX)/Float(material.Width())
		Local t0:Float=Float(image._y+sourceY)/Float(material.Height())
		Local s1:Float=Float(image._x+sourceX+sourceWidth)/Float(material.Width())
		Local t1:Float=Float(image._y+sourceY+sourceHeight)/Float(material.Height())
		DrawRect( x0,y0,width,height,material,s0,t0,s1,t1 )
	End Method
	
	'gradient rect - kinda hacky, but doesn't slow anything else down
	Method DrawGradientRect( x0:Float,y0:Float,width:Float,height:Float,r0:Float,g0:Float,b0:Float,a0:Float,r1:Float,g1:Float,b1:Float,a1:Float,axis:Int )
	
		r0:*_color.r;g0:*_color.g;b0:*_color.b;a0:*_color.a*255 '_alpha
		r1:*_color.r;g1:*_color.g;b1:*_color.b;a1:*_color.a*255 '_alpha
		
		Local pm0:Int=Int( a0 ) Shl 24 | Int( b0*a0 ) Shl 16 | Int( g0*a0 ) Shl 8 | Int( r0*a0 )
		Local pm1:Int=Int( a1 ) Shl 24 | Int( b1*a0 ) Shl 16 | Int( g1*a0 ) Shl 8 | Int( r1*a0 )
		
		Local x1:Float=x0+width
		Local y1:Float=y0+height
		Local s0:Float=0.0
		Local t0:Float=0.0
		Local s1:Float=1.0
		Local t1:Float=1.0
		
		BeginPrim( Null,4 )

		Local pmcolor:Int=_pmcolor
		
		BeginPrim( Null,4 )
		
		Select axis
		Case 0	'left->right
			_pmcolor=pm0
			PrimVert( x0,y0,s0,t0 )
			_pmcolor=pm1
			PrimVert( x1,y0,s1,t0 )
			PrimVert( x1,y1,s1,t1 )
			_pmcolor=pm0
			PrimVert( x0,y1,s0,t1 )
		Default	'top->bottom
			_pmcolor=pm0
			PrimVert( x0,y0,s0,t0 )
			PrimVert( x1,y0,s1,t0 )
			_pmcolor=pm1
			PrimVert( x1,y1,s1,t1 )
			PrimVert( x0,y1,s0,t1 )
		End Select
		
		_pmcolor=pmcolor
	End Method
	
	Method DrawImage( image:TImage )
		BeginPrim( image._material,4 )
		PrimVert( image._x0,image._y0,image._s0,image._t0 )
		PrimVert( image._x1,image._y0,image._s1,image._t0 )
		PrimVert( image._x1,image._y1,image._s1,image._t1 )
		PrimVert( image._x0,image._y1,image._s0,image._t1 )
		If image._caster Then AddShadowCaster( image._caster )
	End Method
	
	Method DrawImage( image:TImage,tx:Float,ty:Float )
		PushMatrix()
		Translate( tx,ty )
		DrawImage( image )
		PopMatrix()
	End Method

	Method DrawImage( image:TImage,tx:Float,ty:Float,rz:Float )
		PushMatrix()
		TranslateRotate( tx,ty,rz )
		DrawImage( image )
		PopMatrix()
	End Method
	
	Method DrawImage( image:TImage,tx:Float,ty:Float,rz:Float,sx:Float,sy:Float )
		PushMatrix()
		TranslateRotateScale( tx,ty,rz,sx,sy )
		DrawImage( image )
		PopMatrix()
	End Method
	
	Rem
	bbdoc: Draws @text at @x,@y in the current font.
	End Rem
	Rem
	Method DrawText( text:String,x:Float,y:Float,xhandle:Float=0,yhandle:Float=0 )
		x:-_font.TextWidth( text )*xhandle
		y:-_font.TextHeight( text )*yhandle
		
		Local sx:Float=x
		
		For Local char:Int=EachIn Text
			
			Select char
			Case 10,13
				x=sx
				y:+_font._height+_font._lineKerning
				Continue
			End Select
			
			Local glyph:TGlyph=_font.GetGlyph( char )
			If Not glyph Continue
			DrawRect( x+glyph.offset,y,glyph.image,glyph.x,glyph.y,glyph.width,glyph.height )
			x:+glyph.advance+glyph.offset
		Next
	End Method
	End Rem
	Method DrawText( text:String,x:Float,y:Float,xHandle:Float=0,yHandle:Float=0 )
		Local sz:Float[]=_font.TextSize( text )
		
		x:-sz[0]*xHandle
		y:-sz[1]*yHandle
		
		Local inTag:Int
		Local tag:String
		
		Local del:Int,ins:Int,bold:Int,swear:Int,ha:Int,va:Int,jump:Int
		Local rgba:Int[8],index:Int=-1
		
		'Local col:Float[]=Color()
		Local col:SColorF=Color()
		
		Local cx:Float=x
		Local cy:Float=y
		
		Local time:Int=MilliSecs()
		
		Local i:Int=0
		For Local char:Int=EachIn text
			i:+1
			
			Select char
			Case 10
				cx=x
				cy:+_font.TextHeight( char )+_font._lineKerning
				Continue
			Case TFont.openTagAsc
				inTag=True
				tag=""
				Continue
			End Select
			
			If inTag
				If char=TFont.closeTagAsc
					inTag=False
					Select tag
					Case "del"				del:+1
					Case "/del","\del"		del:-1		
					Case "ins"				ins:+1
					Case "/ins","\ins"		ins:-1
					Case "b"				bold:+1
					Case "/b","\b"			bold:-1
					'Case "i"			
					'Case "/i","\i"
					Case "swear"			swear:+1
					Case "/swear","\swear"	swear:-1
					Case "ha"				ha:+1
					Case "/ha","\ha"		ha:-1
					Case "va"				va:+1
					Case "/va","\va"		va:-1
					Case "jump"				jump:+1
					Case "/jump","\jump"	jump:-1
					Case "/#","\#","/$","\$"
						index:-1
						If index<0
							Color( col ) '.r,col.g,col.b,col.a )
						Else
							Color( rgba[index] )
						End If
					Default
						If tag.StartsWith( "#" ) Then tag="$"+tag[1..]
						If tag.StartsWith( "$" )
							index:+1
							rgba[index]=tag.ToInt()
							Color( rgba[index] )
						End If 
					End Select
				Else
					tag:+Chr( char )
				EndIf
				Continue
			End If
			
			Local glyph:TGlyph=_font.GetGlyph( char )
			If Not glyph Then Continue
			
			Local ox:Int=glyph.offset
			Local oy:Int
			
			Local tx:Float=cx+ox
			Local ty:Float=cy+oy
			
			If swear
				Local ang:Float=Rnd( time )
				tx:+Float( Cos( ang ) )*0.5
				ty:+Float( Sin( ang ) )*0.5
			End If
			
			If jump Then ty:+Float( Sin( time ) )
			
			If ha Then ty:+Float( Sin( time+i*90.0 ) )
			If va Then tx:+Float( Sin( time+i*90.0 ) )
			
			If _font._shadow
				Local c:SColorF=Color()
				Color( _font._shadowColor[0],_font._shadowColor[1],_font._shadowColor[2],_font._shadowColor[3] )'shadowR/255.0,shadowG/255.0,shadowB/255.0 )
				DrawRect( tx+_font._shadowOffset[0],ty+_font._shadowOffset[1],glyph.image,glyph.x,glyph.y,glyph.width,glyph.height )
				Color( c ) '.r,c.g,c.b,c[3] )
			EndIf
			DrawRect( tx,ty,glyph.image,glyph.x,glyph.y,glyph.width,glyph.height )
			
			If ins
			
			EndIf
			
			If del
			
			EndIf
			
			cx:+glyph.advance+glyph.offset
		Next
	End Method
	
	Method DrawText( text:String,x:Float,y:Float,xHandle:Float=0,yHandle:Float=0,align:Int )
		Local w:Float=_font.TextWidth( text )
		Local h:Float=_font.TextHeight( text )
		x:-w*xHandle
		y:-h*yHandle
		
		Local lines:String[]=text.Split( "~n" )
		
		Local sy:Float=y
		For Local line:String=EachIn lines
			Select align
			Case -1 DrawText( line,x,sy )
			Case 0  DrawText( line,x+w*0.5,sy,0.5 )
			Case 1  DrawText( line,x+w,sy,1.0 )
			End Select
			sy:+_font._height+_font._lineKerning
		Next
	End Method
	
	Rem
	bbdoc: Draws a shadow volume.
	End Rem
	Method DrawShadow:Int( lx:Float,ly:Float,x0:Float,y0:Float,x1:Float,y1:Float )
	
		Local ext:Int=1024
	
		Local dx:Float=x1-x0
		Local dy:Float=y1-y0
		Local d0:Float=Sqr( dx*dx+dy*dy )
		Local nx:Float=-dy/d0
		Local ny:Float=dx/d0
		Local pd:Float=-( x0*nx+y0*ny )
		
		Local d:Float=lx*nx+ly*ny+pd
		If d<0 Return False

		Local x2:Float=x1-lx
		Local y2:Float=y1-ly
		'Local d2:Float=ext/Sqr( x2*x2+y2*y2 )
		x2=lx+x2*ext;y2=ly+y2*ext
		
		Local x3:Float=x0-lx
		Local y3:Float=y0-ly
		'Local d3:Float=ext/Sqr( x3*x3+y3*y3 )
		x3=lx+x3*ext;y3=ly+y3*ext
		
		Local x4:Float=( x2+x3 )/2-lx
		Local y4:Float=( y2+y3 )/2-ly
		'Local d4:Float=ext/Sqr( x4*x4+y4*y4 )
		x4=lx+x4*ext;y4=ly+y4*ext
		
		DrawTriangle( x0,y0,x4,y4,x3,y3 )
		DrawTriangle( x0,y0,x1,y1,x4,y4 )
		DrawTriangle( x1,y1,x2,y2,x4,y4 )
		
		Return True
	End Method
	
	Rem
	bbdoc: Draws multiple shadow volumes.
	end rem
	Method DrawShadow( x0:Float,y0:Float,drawList:TDrawList )
	
		Local lx:Float= x0 * _ix + y0 * _jx + _tx
		Local ly:Float= x0 * _iy + y0 * _jy + _ty

		Local verts:Float[]=drawList._casterVerts.Data
		Local v0:Int=0
		
		For Local i:Int=0 Until drawList._casters.Length
		
			Local caster:TShadowCaster=drawList._casters.Get( i )
			Local n:Int=caster._verts.Length
			
			Select caster._kind
			Case 0	'closed loop
				Local x0:Float=verts[v0+n-2]
				Local y0:Float=verts[v0+n-1]
				For Local i:Int=0 Until n-1 Step 2
					Local x1:Float=verts[v0+i]
					Local y1:Float=verts[v0+i+1]
					DrawShadow( lx,ly,x0,y0,x1,y1 )
					x0=x1
					y0=y1
				Next
			Case 1	'open loop
			Case 2	'edge soup
			End Select
			
			v0:+n
		Next
		
	End Method
	
	Rem
	bbdoc: Adds a shadow caster to the drawlist.
	end rem
	Method AddShadowCaster( caster:TShadowCaster )
		_casters.Push( caster )
		Local verts:Float[]=caster._verts
		For Local i:Int=0 Until verts.Length-1 Step 2
			Local x0:Float=verts[i]
			Local y0:Float=verts[i+1]
			_casterVerts.Push( x0*_ix+y0*_jx+_tx )
			_casterVerts.Push( x0*_iy+y0*_jy+_ty )
		Next
	End Method
	
	Rem
	bbdoc: Adds a shadow caster to the drawlist at @tx,@ty.
	end rem
	Method AddShadowCaster( caster:TShadowCaster,tx:Float,ty:Float )
		PushMatrix()
		Translate( tx,ty )
		AddShadowCaster( caster )
		PopMatrix()
	End Method
	
	Method AddShadowCaster( caster:TShadowCaster,tx:Float,ty:Float,rz:Float )
		PushMatrix()
		TranslateRotate( tx,ty,rz )
		AddShadowCaster( caster )
		PopMatrix()
	End Method
	
	Method AddShadowCaster( caster:TShadowCaster,tx:Float,ty:Float,rz:Float,sx:Float,sy:Float )
		PushMatrix()
		TranslateRotateScale( tx,ty,rz,sx,sy )
		AddShadowCaster( caster )
		PopMatrix()
	End Method
	
	Method IsEmpty:Int()
		Return _next=0
	End Method
	
	Method Compact()
		If _data.Length=_next Return
		'Local data:TBank=New TBank.Create( _next )
		'MemCopy( data._buf,_data._buf,Size_T(_next) )
		'_data=data
		_data=_data[.._next]
	End Method
	
	Method RenderOp( op:TDrawOp,index:Int,count:Int )
	
		If Not op.material.Bind() Then Return
		
		If op.blend<>Mojo.rs_blend
			Mojo.rs_blend=op.blend
			Select Mojo.rs_blend
			Case TBlendMode.Opaque glDisable( GL_BLEND )
			Case TBlendMode.Alpha
				glEnable( GL_BLEND )
				glBlendFunc( GL_ONE,GL_ONE_MINUS_SRC_ALPHA )
			Case TBlendMode.Additive
				glEnable( GL_BLEND )
				glBlendFunc( GL_ONE,GL_ONE )
			Case TBlendMode.Multiply
				glEnable( GL_BLEND )
				glBlendFunc( GL_DST_COLOR,GL_ONE_MINUS_SRC_ALPHA )
			Case TBlendMode.Multiply2
				glEnable( GL_BLEND )
				glBlendFunc( GL_DST_COLOR,GL_ZERO )
			Case TBlendMode.Overlay
				glEnable( GL_BLEND )
				glBlendFunc( GL_DST_COLOR,GL_SRC_ALPHA )
			End Select
		End If
		
		Select op.order
		Case 1 glDrawArrays( GL_POINTS,index,count )
		Case 2 glDrawArrays( GL_LINES,index,count )
		Case 3 glDrawArrays( GL_TRIANGLES,index,count )
		Case 4
			glDrawElements( ..
			GL_TRIANGLES,count/4*6,GL_UNSIGNED_SHORT,Byte Ptr((index/4*6 + (index&3)*MAX_QUAD_INDICES)*2) )
		Default
			Local j:Int=0
			While j<count
				glDrawArrays( GL_TRIANGLE_FAN,index+j,op.order )
				j:+op.order
			Wend
		End Select
	End Method
	
	Method Render()
		If Not _next Then Return
		
		Local offset:Int=0
		Local opid:Int=0
		Local ops:Object[]=_ops.Data
		Local length:Int=_ops.length
				
		While offset<_next
		
			Local size:Int=_next-offset
			Local lastop:Int=length
			
			If size>PRIM_VBO_SIZE
			
				size=0
				lastop=opid
				While lastop<length
					Local op:TDrawOp=TDrawOp( ops[lastop] )
					Local n:Int=op.count*BYTES_PER_VERTEX
					If size+n>PRIM_VBO_SIZE Exit
					size:+n
					lastop:+1
				Wend
				
				If Not size
					Local op:TDrawOp=TDrawOp( ops[opid] )
					Local count:Int=op.count
					While count
						Local n:Int=count
						If n>MAX_VERTICES Then n=MAX_VERTICES/op.order*op.order
						Local size:Int=n*BYTES_PER_VERTEX
						
						If VBO_ORPHANING_ENABLED glBufferData( GL_ARRAY_BUFFER,PRIM_VBO_SIZE,Null,VBO_USAGE )
						'glBufferSubData( GL_ARRAY_BUFFER,0,size,_data._buf+offset )
						glBufferSubData( GL_ARRAY_BUFFER,0,size,Varptr _data[offset] )
						
						RenderOp( op,0,n )
						
						offset:+size
						count:-n
					Wend
					opid:+1
					Continue
				EndIf
				
			EndIf
			
			If VBO_ORPHANING_ENABLED Then glBufferData( GL_ARRAY_BUFFER,PRIM_VBO_SIZE,Null,VBO_USAGE )
			'glBufferSubData( GL_ARRAY_BUFFER,0,size,_data._buf+offset )
			glBufferSubData( GL_ARRAY_BUFFER,0,size,Varptr _data[offset] )
			
			Local index:Int=0
			While opid<lastop
				Local op:TDrawOp=TDrawOp( ops[opid] )
				RenderOp( op,index,op.count )
				index:+op.count
				opid:+1
			Wend
			offset:+size
		Wend
		
		glGetError()
	End Method
	
	Method Reset()
		_next=0
		
		Local data:TDrawOp[]=_ops.Data
		For Local i:Int=0 Until _ops.Length
			data[i].material=Null
			Mojo.freeOps.Push( data[i] )
		Next
		_ops.Clear()
		_op=Mojo.nullOp
		
		_casters.Clear()
		_casterVerts.Clear()
	End Method
	
	Method Flush()
		Render()
		Reset()
	End Method
	
	Protected

	Field _blend:Int=1
	'Field _color:Float[]=[1.0,1.0,1.0,1.0]
	Field _color:SColorF
	Field _pmcolor:Int=$ffffffff
	
	Field _ix:Float=1,_iy:Float
	Field _jx:Float,_jy:Float=1
	Field _tx:Float,_ty:Float
	Field _matStack:Float[64*6]
	Field _matSp:Int
	Field _font:TFont
	Field _defaultMaterial:TMaterial
	
	Field _matRet:Float[6]
	'Field _colRet:Float[4]
	
	Private
	
	'Field _data:TBank=New TBank.Create( 4096 )
	Field _data:Byte[4096]
	Field _next:Int=0
	
	Field _op:TDrawOp=Mojo.nullOp
	Field _ops:TDrawOpStack=New TDrawOpStack'<DrawOp>
	Field _casters:TShadowCasterStack=New TShadowCasterStack'<ShadowCaster>
	Field _casterVerts:TFloatStack=New TFloatStack

	Method BeginPrim( material:TMaterial,order:Int ) Final
	
		If Not material Then material=_defaultMaterial
		
		If _next+order*BYTES_PER_VERTEX>_data.Length 'Size()
			'Local newsize:Int=Max( _data.Size()+_data.Size()/2,_next+order*BYTES_PER_VERTEX )
			Local newsize:Int=Max( _data.Length+_data.Length Shr 1,_next+order*BYTES_PER_VERTEX )
			'Local data:TBank=New TBank.Create( newsize )
			'MemCopy( data._buf,_data._buf,Size_T( _next ) )
			'_data=data
			_data=_data[..newsize]
		EndIf
	
		If material=_op.material And _blend=_op.blend And order=_op.order
			_op.count:+order
			Return
		EndIf
		
		If Mojo.freeOps.Length Then _op=Mojo.freeOps.Pop() Else _op=New TDrawOp
		
		_ops.Push( _op )
		_op.material=material
		_op.blend=_blend
		_op.order=order
		_op.count=order
	End Method
	
	Method BeginPrim( material:TMaterial,order:Int,count:Int ) Final
	
		If Not material Then material=_defaultMaterial
		
		count:*order
		
		If _next+count*BYTES_PER_VERTEX>_data.Length 'Size()
			Local newsize:Int=Max( _data.Length+_data.Length Shr 1,_next+count*BYTES_PER_VERTEX )
			'Local data:TBank=New TBank.Create( newsize )
			'MemCopy( data._buf,_data._buf,Size_T( _next ) )
			'_data=data
			_data=_data[..newsize]
		EndIf
	
		If material=_op.material And _blend=_op.blend And order=_op.order
			_op.count:+count
			Return
		EndIf
		
		If Mojo.freeOps.Length Then _op=Mojo.freeOps.Pop() Else _op=New TDrawOp
		
		_ops.Push( _op )
		_op.material=material
		_op.blend=_blend
		_op.order=order
		_op.count=count
	End Method
	
	Method PrimVert( x0:Float,y0:Float,s0:Float,t0:Float ) Final
		Local df:Float Ptr=Float Ptr( Varptr _data[_next] ) '_data._buf+_next )
		Local di:Int Ptr=Int Ptr( Varptr _data[_next] ) ' _data._buf+_next )
		df[0]=x0*_ix+y0*_jx+_tx
		df[1]=x0*_iy+y0*_jy+_ty
		df[2]=s0
		df[3]=t0
		df[4]=_ix
		df[5]=_iy
		di[6]=_pmcolor
		_next:+BYTES_PER_VERTEX
	End Method
End Type


'***** Canvas *****

Type TCanvas Extends TDrawList

	Const MaxLights:Int=MAX_LIGHTS
	
	Method New( width:Int,height:Int )
		Super.New()
		RenderTarget( width,height )
		Viewport( 0,0,_width,_height )
		SetProjection2d( 0,_width,0,_height )
	End Method
	
	Method New( target:TTexture )
		Super.New()
		RenderTarget( target )
		Viewport( 0,0,_width,_height )
		SetProjection2d( 0,_width,0,_height )
	End Method
	
	Method New( target:TImage )
		Super.New()
		RenderTarget( target )
		Viewport( 0,0,_width,_height )
		SetProjection2d( 0,_width,0,_height )
	End Method
	
	Method RenderTarget( width:Int,height:Int )
		FlushPrims()
		
		_image=Null
		_texture=Null
		_width=width 'GraphicsWidth()
		_height=height 'GraphicsHeight()
		_twidth=_width
		_theight=_height
		
		_dirty=-1
	End Method
	
	Method RenderTarget( image:TImage )
		FlushPrims()
		
		_image=image
		_texture=_image.Material().ColorTexture()
			
		If Not ( _texture.Flags()&TTexture.RenderTarget ) Throw "Texture is not a render target texture"
		_width=_image.Width()
		_height=_image.Height()
		_twidth=_texture.Width()
		_theight=_texture.Height()
		
		_dirty=-1
	End Method
	
	Method RenderTarget( texture:TTexture )
		FlushPrims()
		
		_image=Null
		_texture=texture

		If Not ( _texture.Flags()&TTexture.RenderTarget ) Throw "Texture is not a render target texture"
		_width=_texture.Width()
		_height=_texture.Height()
		_twidth=_texture.Width()
		_theight=_texture.Height()
		
		_dirty=-1
	End Method

	Method RenderTarget:Object()
		If _image Then Return _image Else Return _texture
	End Method
	
	Method Width:Int()
		Return _width
	End Method
	
	Method Height:Int()
		Return _height
	End Method
	
	Method ColorMask( r:Int,g:Int,b:Int,a:Int )
		FlushPrims()
		_colorMask[0]=r
		_colorMask[1]=g
		_colorMask[2]=b
		_colorMask[3]=a
		_dirty:|DIRTY_COLORMASK
	End Method
	
	Method ColorMask:Int[]()
		Return _colorMask
	End Method
	
	Method Viewport( x:Int,y:Int,w:Int,h:Int )
		FlushPrims()
		_viewport[0]=x
		_viewport[1]=y
		_viewport[2]=w
		_viewport[3]=h
		_dirty:|DIRTY_VIEWPORT
	End Method
	
	Method Viewport:Int[]()
		Return _viewport
	End Method
	
	Method Scissor( x:Int,y:Int,w:Int,h:Int )
		FlushPrims()
		_scissor[0]=x
		_scissor[1]=y
		_scissor[2]=w
		_scissor[3]=h
		_dirty:|DIRTY_VIEWPORT
	End Method
	
	Method Scissor:Int[]()
		Return _scissor
	End Method
	
	Method ProjectionMatrix( projMatrix:Float[] )
		FlushPrims()
		If projMatrix
			Mat4Copy( projMatrix,_projMatrix )
		Else
			Mat4InitArray( _projMatrix )
		EndIf
		_dirty:|DIRTY_SHADER
	End Method
	
	Method SetProjection2d( Left:Float,Right:Float,top:Float,bottom:Float,znear:Float=-1,zfar:Float=1 )
		FlushPrims()
		Mat4Ortho( Left,Right,top,bottom,znear,zfar,_projMatrix )
		_dirty:|DIRTY_SHADER
	End Method
	
	Method ProjectionMatrix:Float[]()
		Return _projMatrix
	End Method
	
	Method ViewMatrix( viewMatrix:Float[] )
		FlushPrims()
		If viewMatrix
			Mat4Copy( viewMatrix,_viewMatrix )
		Else
			Mat4InitArray( _viewMatrix )
		End If
		_dirty:|DIRTY_SHADER
	End Method
	
	Method ViewMatrix:Float[]()
		Return _viewMatrix
	End Method
	
	Method ModelMatrix( modelMatrix:Float[] )
		FlushPrims()
		If modelMatrix
			Mat4Copy( modelMatrix,_modelMatrix )
		Else
			Mat4InitArray( _modelMatrix )
		EndIf
		_dirty:|DIRTY_SHADER
	End Method
	
	Method ModelMatrix:Float[]()
		Return _modelMatrix
	End Method

	Method AmbientLight( r:Float,g:Float,b:Float,a:Float=1 )
		AmbientLight( New SColorF( r,g,b,a ) )
		'FlushPrims()
		'_ambientLight[0]=r
		'_ambientLight[1]=g
		'_ambientLight[2]=b
		'_ambientLight[3]=a
		'_dirty:|DIRTY_SHADER
	End Method
	
	Method AmbientLight( color:SColorF )
		FlushPrims()
		_ambientLight=color
		_dirty:|DIRTY_SHADER
	End Method
	
	Method AmbientLight:SColorF()
		Return _ambientLight
	End Method
	
	Method FogColor( r:Float,g:Float,b:Float,a:Float )
		FogColor( New SColorF( r,g,b,a ) )
	End Method
	
	Method FogColor( color:SColorF )
		FlushPrims()
		_fogColor=color
		_dirty:|DIRTY_SHADER
	End Method
	
	Method FogColor:SColorF()
		Return _fogColor
	End Method
	
	Method LightType( index:Int,kind:Int )
		FlushPrims()
		_lights[index].kind=kind
		_dirty:|DIRTY_SHADER
	End Method
	
	Method LightType:Int( index:Int )
		Return _lights[index].kind
	End Method
	
	Method LightColor( index:Int,r:Float,g:Float,b:Float,a:Float=1 )
		LightColor( index,New SColorF( r,g,b,a ) )
	End Method
	
	Method LightColor( index:Int,color:SColorF )
		FlushPrims()
		_lights[index].color=color
		_dirty:|DIRTY_SHADER
	End Method
	
	Method LightColor:SColorF( index:Int )
		Return _lights[index].color
	End Method
	
	Method LightPosition( index:Int,x:Float,y:Float,z:Float )
		FlushPrims()
		'Local light:TLightData=_lights[index]
		_lights[index].position[0]=x
		_lights[index].position[1]=y
		_lights[index].position[2]=z
		_lights[index].vector[0]=x
		_lights[index].vector[1]=y
		_lights[index].vector[2]=z
		_dirty:|DIRTY_SHADER
	End Method
	
	Method LightPosition:Float[]( index:Int )
		Return _lights[index].position
	End Method
	
	Method LightRange( index:Int,Range:Float )
		FlushPrims()
		'Local light:TLightData=_lights[index]
		_lights[index].Range=Range
		_dirty:|DIRTY_SHADER
	End Method
	
	Method LightRange:Float( index:Int )
		Return _lights[index].Range
	End Method
	
	Method ShadowMap( image:TImage )
		FlushPrims()
		_shadowMap=image
		_dirty:|DIRTY_SHADER
	End Method
	
	Method ShadowMap:TImage()
		Return _shadowMap
	End Method
	
	Method LineWidth( lineWidth:Float )
		FlushPrims()
		_lineWidth=lineWidth
		_dirty:|DIRTY_LINEWIDTH
	End Method
	
	Method LineWidth:Float()
		Return _lineWidth
	End Method
	
	Method Clear( r:Float=0,g:Float=0,b:Float=0,a:Float=1 )
		FlushPrims()
		Validate()
		If _clsScissor
			glEnable( GL_SCISSOR_TEST )
			glScissor( _vpx,_vpy,_vpw,_vph )
		EndIf
		glClearColor( r,g,b,a )
		glClear( GL_COLOR_BUFFER_BIT )
		If _clsScissor Then glDisable( GL_SCISSOR_TEST )
	End Method
	
	Method ReadPixels( x:Int,y:Int,width:Int,height:Int,data:TBank,dataOffset:Int=0,dataPitch:Int=0 )
		FlushPrims()
		
		If Not dataPitch Or dataPitch=width*4
			glReadPixels( x,y,width,height,GL_RGBA,GL_UNSIGNED_BYTE,data._buf+dataOffset )
		Else
			For Local iy:Int=0 Until height
				glReadPixels( x,y+iy,width,1,GL_RGBA,GL_UNSIGNED_BYTE,data._buf+dataOffset+dataPitch*iy )
			Next
		EndIf
	End Method

	Method RenderDrawList( drawbuf:TDrawList )

		If _ix=1 And _iy=0 And _jx=0 And _jy=1 And _tx=0 And _ty=0 And _color=SColorF.White
		   '_color.r=1 And _color.g=1 And _color.b=1 And _color.a=1
			
			FlushPrims()
			Validate()
			drawbuf.Render()
			Return
		EndIf
		
		Mojo.tmpMat3d[0]=_ix
		Mojo.tmpMat3d[1]=_iy
		Mojo.tmpMat3d[4]=_jx
		Mojo.tmpMat3d[5]=_jy
		Mojo.tmpMat3d[12]=_tx
		Mojo.tmpMat3d[13]=_ty
		Mojo.tmpMat3d[10]=1
		Mojo.tmpMat3d[15]=1
		
		Mat4Multiply( _modelMatrix,Mojo.tmpMat3d,Mojo.tmpMat3d2 )
		
		FlushPrims()
		
		Local tmp:Float[]=_modelMatrix
		_modelMatrix=Mojo.tmpMat3d2
		Mojo.rs_globalColor[0]=_color.r*_color.a '[3]
		Mojo.rs_globalColor[1]=_color.g*_color.a '[3]
		Mojo.rs_globalColor[2]=_color.b*_color.a '[3]
		Mojo.rs_globalColor[3]=_color.a
		_dirty:|DIRTY_SHADER
		
		Validate()
		If drawbuf Then drawbuf.Render()
		
		_modelMatrix=tmp
		Mojo.rs_globalColor[0]=1
		Mojo.rs_globalColor[1]=1
		Mojo.rs_globalColor[2]=1
		Mojo.rs_globalColor[3]=1
		_dirty:|DIRTY_SHADER
	End Method
	
	Method RenderDrawList( drawList:TDrawList,tx:Float,ty:Float )
		Super.PushMatrix()
		Super.Translate( tx,ty )
		RenderDrawList( drawList )
		Super.PopMatrix()
	End Method
	
	Method RenderDrawList( drawList:TDrawList,tx:Float,ty:Float,rz:Float )
		Super.PushMatrix()
		Super.TranslateRotate( tx,ty,rz )
		RenderDrawList( drawList )
		Super.PopMatrix()
	End Method
	
	Method RenderDrawList( drawList:TDrawList,tx:Float,ty:Float,rz:Float,sx:Float,sy:Float )
		Super.PushMatrix()
		Super.TranslateRotateScale( tx,ty,rz,sx,sy )
		RenderDrawList( drawList )
		Super.PopMatrix()
	End Method

	Method Flush()
		FlushPrims()
		
		If Not _texture Then Return
		
		If _texture.Flags()&TTexture.Managed
			Validate()

			glDisable( GL_SCISSOR_TEST )
			glViewport( 0,0,_twidth,_theight )
			
			If _width=_twidth And _height=_theight
				glReadPixels( 0,0,_twidth,_theight,GL_RGBA,GL_UNSIGNED_BYTE,_texture.Data().pixels )
			Else
				For Local y:Int=0 Until _height
					glReadPixels( _image._x,_image._y+y,_width,1,GL_RGBA,GL_UNSIGNED_BYTE,..
					_texture.Data().pixels+( _image._y+y )*( _twidth*4 )+( _image._x*4 ) )
				Next
			EndIf

			_dirty:|DIRTY_VIEWPORT
		EndIf

		_texture.UpdateMipmaps()
	End Method
	
	Global _tformInvProj:Float[16]
	Global _tformT:Float[]=[0.0,0.0,-1.0,1.0]
	Global _tformP:Float[4]
	
	Method TransformCoords( coords_in:Float[],coords_out:Float[],mode:Int=0 )
	
		Mat4Inverse( _projMatrix,_tformInvProj )

		Select mode
		Case 0 'from window to canvas
			_tformT[0]=(coords_in[0]-_viewport[0])/_viewport[2]*2-1
			_tformT[1]=(coords_in[1]-_viewport[1])/_viewport[3]*2-1
			Mat4Transform( _tformInvProj,_tformT,_tformP )
			_tformP[0]:/_tformP[3]
			_tformP[1]:/_tformP[3]
			_tformP[2]:/_tformP[3]
			_tformP[3]=1
			coords_out[0]=_tformP[0]
			coords_out[1]=_tformP[1]
			If coords_out.Length>2 Then coords_out[2]=_tformP[2]
		Case 1 'from canvas to window
			_tformT[0]=(coords_in[0])'-_viewport[0])/_viewport[2]*2-1
			_tformT[1]=(coords_in[1])'-_viewport[1])/_viewport[3]*2-1
			Mat4Transform( _tformInvProj,_tformT,_tformP )
			_tformP[0]:/_tformP[3]
			_tformP[1]:/_tformP[3]
			_tformP[2]:/_tformP[3]
			_tformP[3]=1
			coords_out[0]=_tformP[0]
			coords_out[1]=_tformP[1]
			If coords_out.Length>2 Then coords_out[2]=_tformP[2]
		Default
			Throw "Invalid TransformCoords mode"
		End Select
	End Method
	
	Private
	
	Global _active:TCanvas

	Const DIRTY_RENDERTARGET:Int=1
	Const DIRTY_VIEWPORT:Int=2
	Const DIRTY_SHADER:Int=4
	Const DIRTY_LINEWIDTH:Int=8
	Const DIRTY_COLORMASK:Int=16
	
	'Field _seq:Int
	Field _dirty:Int=-1
	Field _image:TImage
	Field _texture:TTexture	
	Field _width:Int
	Field _height:Int
	Field _twidth:Int
	Field _theight:Int
	Field _shadowMap:TImage
	Field _colorMask:Int[]=[True,True,True,True]
	Field _viewport:Int[]=[0,0,640,480]
	Field _scissor:Int[]=[0,0,100000,100000]
	Field _vpx:Int,_vpy:Int,_vpw:Int,_vph:Int
	Field _scx:Int,_scy:Int,_scw:Int,_sch:Int
	Field _clsScissor:Int
	Field _projMatrix:Float[]=Mat4New()
	Field _invProjMatrix:Float[]=Mat4New()
	Field _viewMatrix:Float[]=Mat4New()
	Field _modelMatrix:Float[]=Mat4New()
	Field _ambientLight:SColorF=SColorF.Black 'Float[]=[0.0,0.0,0.0,1.0]
	Field _fogColor:SColorF=SColorF.None 'Float[]=[0.0,0.0,0.0,0.0]
	Field _lights:SLightData[4]
	Field _lineWidth:Float=1

	Method FlushPrims()
		If Super.IsEmpty() Return
		Validate()
		Super.Flush()
	End Method
	
	Method Validate()
		'If _seq<>Mojo.graphicsSeq	
		'	_seq=Mojo.graphicsSeq
			'InitVbos()
		'	_dirty=-1
		'EndIf
	
		If _active=Self
			If Not _dirty Then Return
		Else
			If _active Then _active.Flush()
			_active=Self
			_dirty=-1
		EndIf

'		_dirty=-1
		
		If _dirty&DIRTY_RENDERTARGET
			Local fb:Int=Mojo.defaultFbo
			If _texture Then fb=_texture.GLFramebuffer()
			glBindFramebuffer( GL_FRAMEBUFFER,fb )
		EndIf
		
		If _dirty&DIRTY_VIEWPORT
			_vpx=_viewport[0];_vpy=_viewport[1];_vpw=_viewport[2];_vph=_viewport[3]
			If _image
				_vpx:+_image._x
				_vpy:+_image._y
			EndIf
			
			_scx=_scissor[0];_scy=_scissor[1];_scw=_scissor[2];_sch=_scissor[3]
			
			If _scx<0 Then _scx=0 ElseIf _scx>_vpw Then _scx=_vpw
			If _scw<0 Then _scw=0 ElseIf _scx+_scw>_vpw Then _scw=_vpw-_scx
			
			If _scy<0 Then _scy=0 ElseIf _scy>_vph Then _scy=_vph
			If _sch<0 Then _sch=0 ElseIf _scy+_sch>_vph Then _sch=_vph-_scy
			
			_scx:+_vpx;_scy:+_vpy
		
			If Not _texture
				_vpy=_theight-_vpy-_vph
				_scy=_theight-_scy-_sch
			EndIf
			
			glViewport( _vpx,_theight-_vpy-_vph,_vpw,_vph )
			
			If _scx<>_vpx Or _scy<>_vpy Or _scw<>_vpw Or _sch<>_vph
				glEnable( GL_SCISSOR_TEST )
				glScissor( _scx,_scy,_scw,_sch )
				_clsScissor=False
			Else
				glDisable( GL_SCISSOR_TEST )
				_clsScissor=( _scx<>0 Or _scy<>0 Or _vpw<>_twidth Or _vph<>_theight )
			EndIf
			
		EndIf
		
		If _dirty&DIRTY_SHADER
		
			Mojo.rs_program=Null
			
			If _texture
				Mojo.rs_clipPosScale[1]=1
				Mat4Copy( _projMatrix,Mojo.rs_projMatrix )
			Else
				Mojo.rs_clipPosScale[1]=-1
				Mat4Multiply( Mojo.flipYMatrix,_projMatrix,Mojo.rs_projMatrix )
			EndIf
			
			Mat4Multiply( _viewMatrix,_modelMatrix,Mojo.rs_modelViewMatrix )
			Mat4Multiply( Mojo.rs_projMatrix,Mojo.rs_modelViewMatrix,Mojo.rs_modelViewProjMatrix )
			'Vec4Copy( _ambientLight,Mojo.rs_ambientLight )
			'Vec4Copy( _fogColor,Mojo.rs_fogColor )
			Mojo.rs_ambientLight=_ambientLight
			Mojo.rs_fogColor=_fogColor
			
			Mojo.rs_numLights=0
			For Local i:Int=0 Until MAX_LIGHTS

				'Local light:TLightData=_lights[i]
				'If Not light.kind Continue
				If Not _lights[i].kind Then Continue
				
				Mat4Transform( _viewMatrix,_lights[i].vector,_lights[i].tvector )
				
				'Mojo.rs_lightColors[Mojo.rs_numLights*4+0]=_lights[i].color.r '[0]
				'Mojo.rs_lightColors[Mojo.rs_numLights*4+1]=_lights[i].color.g '[1]
				'Mojo.rs_lightColors[Mojo.rs_numLights*4+2]=_lights[i].color.b '[2]
				'Mojo.rs_lightColors[Mojo.rs_numLights*4+3]=_lights[i].color.a '[3]
				Mojo.rs_lightColors[Mojo.rs_numLights*4]=_lights[i].color
				
				Mojo.rs_lightVectors[Mojo.rs_numLights*4+0]=_lights[i].tvector[0]
				Mojo.rs_lightVectors[Mojo.rs_numLights*4+1]=_lights[i].tvector[1]
				Mojo.rs_lightVectors[Mojo.rs_numLights*4+2]=_lights[i].tvector[2]
				Mojo.rs_lightVectors[Mojo.rs_numLights*4+3]=_lights[i].Range

				Mojo.rs_numLights:+1
			Next
			
			If _shadowMap
				Mojo.rs_shadowTexture=_shadowMap._material._colorTexture
			Else 
				Mojo.rs_shadowTexture=Null
			EndIf
			
			Mojo.rs_blend=-1
		End If
		
		If _dirty&DIRTY_LINEWIDTH
			glLineWidth( _lineWidth )
		EndIf
		
		If _dirty&DIRTY_COLORMASK
			glColorMask( Byte( _colorMask[0] ),Byte( _colorMask[1] ),Byte( _colorMask[2] ),Byte( _colorMask[3] ) )
		EndIf
		
		_dirty=0
	End Method
End Type

' stacks

'Private

Type TFloatStack
	Field data:Float[]
	Field length:Int

	Method Push( value:Float )
		If length=data.Length
			data=data[..length*2+10]
		EndIf
		data[length]=value
		length:+1
	End Method

	Method Pop:Float()
		length:-1
		Local v:Float=data[length]
		data[length]=Null
		Return v
	End Method

	Method Top:Float()
		Return data[length-1]
	End Method

	Method Clear()
		For Local i:Int=0 Until length
			data[i]=Null
		Next
		length=0
	End Method
End Type

Type TDrawOpStack
	Field data:TDrawOp[]
	Field length:Int

	Method Push( value:TDrawOp )
		If length=data.Length
			data=data[..length*2+10]
		EndIf
		data[length]=value
		length:+1
	End Method

	Method Pop:TDrawOp()
		length:-1
		Local v:TDrawOp=data[length]
		data[length]=Null
		Return v
	End Method

	Method Top:TDrawOp()
		Return data[length-1]
	End Method

	Method Clear()
		For Local i:Int=0 Until length
			data[i]=Null
		Next
		length=0
	End Method
End Type

Type TShadowCasterStack
	Field data:TShadowCaster[]
	Field length:Int

	Method Push( value:TShadowCaster )
		If length=data.Length
			data=data[..length*2+10]
		EndIf
		data[length]=value
		length:+1
	End Method

	Method Pop:TShadowCaster()
		length:-1
		Local v:TShadowCaster=data[length]
		data[length]=Null
		Return v
	End Method

	Method Top:TShadowCaster()
		Return data[length-1]
	End Method

	Method Get:TShadowCaster(index:Int)
		Return data[index]
	End Method
	
	Method Clear()
		For Local i:Int=0 Until length
			data[i]=Null
		Next
		length=0
	End Method
End Type

Type TDrawListStack
	Field data:TDrawList[]
	Field length:Int

	Method Push( value:TDrawList )
		If length=data.Length
			data=data[..length*2+10]
		EndIf
		data[length]=value
		length:+1
	End Method

	Method Pop:TDrawList()
		length:-1
		Local v:TDrawList=data[length]
		data[length]=Null
		Return v
	End Method

	Method Top:TDrawList()
		Return data[length-1]
	End Method
	
	Method Get:TDrawList(index:Int)
		Return data[index]
	End Method

	Method Clear()
		For Local i:Int=0 Until length
			data[i]=Null
		Next
		length=0
	End Method
End Type
