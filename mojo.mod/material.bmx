
'***** Material *****

Public

Rem
bbdoc: Materials contain shader parameters that map to shader uniforms variables when rendering. 
End Rem
Type TMaterial Extends TRefCounted
	Rem
	bbdoc: Creates a new material.
	End Rem
	Method New()
		Mojo.Init()
		_shader=Mojo._defaultShader
		_shader.OnInitMaterial( Self )
		_inited=True
	End Method
	
	Rem
	bbdoc: Creates a new material.
	End Rem
	Method New( shader:TShader )
		Mojo.Init()
		
		If Not shader Then shader=Mojo._defaultShader
		_shader=shader
		_shader.OnInitMaterial( Self )
		_inited=True
	End Method
	
	Method OnDestroy() Override
		For Local tex:TTexture=EachIn _textures
			tex.Free()
		Next
	End Method
	
	Rem
	bbdoc: Gets material shader.
	End Rem
	Method Shader:TShader() 
		Return _shader
	End Method
	
	Method ColorTexture:TTexture()
		Return _colorTexture
	End Method
	
	Method ColorTexture( texture:TTexture )
		SetTexture( "ColorTexture",texture )
	End Method
	
	Method Width:Int()
		If _colorTexture Then Return _colorTexture.Width() Else Return 0
	End Method
	
	Method Height:Int()
		If _colorTexture Then Return _colorTexture.Height() Else Return 0
	End Method
	
	Rem
	bbdoc: Sets float shader parameter.
	End Rem
	Method SetScalar( param:String,scalar:Float )
		'If _inited And Not _scalars.Contains( param ) Then Return
		If _inited And _scalars[param]=Null Then Return
		'_scalars.Insert( param,scalar )
		_scalars[param]=scalar
	End Method
	
	Rem
	bbdoc: Gets float shader parameter.
	End Rem
	Method GetScalar:Float( param:String,defValue:Float=1.0 )
		'If Not _scalars.Contains( param ) Then Return defValue
		'Return _scalars.ValueForKey( param )
		Local f:Float=_scalars[param]
		If f=0 Then Return defValue
		Return f
	End Method
	
	Rem
	bbdoc: Sets vector shader parameter.
	End Rem
	Method SetVector( param:String,vector:Float[] )
		'If _inited And Not _vectors.Contains( param ) Then Return
		'_vectors.Insert( param,vector )
		If _inited And _vectors[param]=Null Then Return
		_vectors[param]=vector
	End Method
	
	Rem
	bbdoc: Gets vector shader parameter.
	End Rem
	Method GetVector:Float[]( param:String,defValue:Float[]=Null )
		Local v:Float[]=Float[]( _vectors[param] )
		
		If Not v 'Not _vectors.Contains( param )
			If defValue
				Return defValue
			Else
				Return [1.0,1.0,1.0,1.0]
			End If
		End If
		Return v 'Float[]( _vectors[param] ) '.ValueForKey( param ) )
	End Method
	
	Rem
	bbdoc: Sets texture shader parameter.
	End Rem
	Method SetTexture( param:String,texture:TTexture )
		If Not texture Then Return
		Local old:TTexture=TTexture( _textures[param] )
		If _inited And old=Null Then Return 'Not _textures.Contains( param ) Then Return
		
		'Local old:TTexture=_textures[param] '.ValueForKey( param ) )
		texture.Retain()
		_textures[param]=texture '.Insert( param,texture )
		If old Then old.Free()
		
		If param="ColorTexture" Then _colorTexture=texture
	End Method
	
	Rem
	bbdoc: Gets texture shader parameter.
	End Rem
	Method GetTexture:TTexture( param:String,defValue:TTexture=Null )
		'If Not _textures.Contains( param ) Then Return defValue
		'Return TTexture( _textures.ValueForKey( param ) )
		Local texture:TTexture=TTexture( _textures[param] )
		If texture Then Return texture
		Return defValue
	End Method
	
	Rem
	bbdoc: Loads a material.
	about: If @shader is null, the TShader.DefaultShader is used.
	End Rem
	Function Load:TMaterial( url:Object,textureFlags:Int,shader:TShader=Null )
		Local material:TMaterial=New TMaterial( shader )
		material=material.Shader().OnLoadMaterial( material,url,textureFlags )
		Return material
	End Function
	
	Private
	
	Field _shader:TShader
	Field _colorTexture:TTexture
	'Field _scalars:TStringFloatMap=New TStringFloatMap
	Field _scalars:THashFloat=New THashFloat

	Field _vectors:THash=New THash 'TStringMap=New TStringMap
	Field _textures:THash=New THash 'TStringMap=New TStringMap

	Field _inited:Int
	
	Method Bind:Int()
	
		_shader.Bind()
		
		If Mojo.rs_material=Self Then Return True
		
		Mojo.rs_material=Self
	
		Local texid:Int=0
		
		For Local u:SGLUniform=EachIn Mojo.rs_program.matuniforms
			Select u.kind
			Case GL_FLOAT 		glUniform1f u.location,GetScalar( u.name )
			Case GL_FLOAT_VEC4 	glUniform4fv u.location,1,GetVector( u.name )
			Case GL_SAMPLER_2D
				Local tex:TTexture=GetTexture( u.name )
'				If tex.Loading
'					rs_material=Null 
'					Exit
'				Endif
				glActiveTexture( GL_TEXTURE0+texid )
				glBindTexture( GL_TEXTURE_2D,tex.GLTexture() )
				glUniform1i( u.location,texid )
				texid:+1
			Default Throw "Unsupported uniform type:"+u.kind 
			End Select
		Next

		If texid Then glActiveTexture( GL_TEXTURE0 )
		
		Return Mojo.rs_material=Self
	End Method
End Type
