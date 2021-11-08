
'***** Shader ****

Private

Struct SGLUniform
	Field name:String
	Field location:Int
	Field size:Int
	Field kind:Int
	
	Method New( name:String,location:Int,size:Int,kind:Int )
		Self.name=name
		Self.location=location
		Self.size=size
		Self.kind=kind
	End Method
End Struct

Struct SGLProgram
	Field ReadOnly program:Int
	Field ReadOnly matuniforms:SGLUniform[] 'material uniforms
	
	'hard coded uniform locations
	Field ReadOnly mvpMatrix:Int
	Field ReadOnly mvMatrix:Int
	Field ReadOnly clipPosScale:Int
	Field ReadOnly globalColor:Int
	Field ReadOnly AmbientLight:Int
	Field ReadOnly fogColor:Int
	Field ReadOnly lightColors:Int
	Field ReadOnly lightVectors:Int
	Field ReadOnly shadowTexture:Int
	
	Method New( program:Int,matuniforms:SGLUniform[] )
		Self.program	=program
		Self.matuniforms=matuniforms
		mvpMatrix		=glGetUniformLocation( program,"ModelViewProjectionMatrix" )
		mvMatrix		=glGetUniformLocation( program,"ModelViewMatrix" )
		clipPosScale	=glGetUniformLocation( program,"ClipPosScale" )
		globalColor		=glGetUniformLocation( program,"GlobalColor" )
		fogColor		=glGetUniformLocation( program,"FogColor" )
		AmbientLight	=glGetUniformLocation( program,"AmbientLight" )
		lightColors		=glGetUniformLocation( program,"LightColors" )
		lightVectors	=glGetUniformLocation( program,"LightVectors" )
		shadowTexture	=glGetUniformLocation( program,"ShadowTexture" )
	End Method
	
	Method Bind()
		glUseProgram( program )
		
		If mvpMatrix<>-1 	Then glUniformMatrix4fv( mvpMatrix,1,False,Mojo.rs_modelViewProjMatrix )
		If mvMatrix<>-1 	Then glUniformMatrix4fv( mvMatrix,1,False,Mojo.rs_modelViewMatrix )
		If clipPosScale<>-1 Then glUniform4fv( clipPosScale,1,Mojo.rs_clipPosScale )
		If globalColor<>-1	Then glUniform4fv( globalColor,1,Mojo.rs_globalColor )
		If fogColor<>-1 	Then glUniform4fv( fogColor,1,Varptr Mojo.rs_fogColor.r )
		If AmbientLight<>-1 Then glUniform4fv( AmbientLight,1,Varptr Mojo.rs_ambientLight.r )
		If lightColors<>-1 	Then glUniform4fv( lightColors,Mojo.rs_numLights,Mojo.rs_lightColors )
		If lightVectors<>-1 Then glUniform4fv( lightVectors,Mojo.rs_numLights,Mojo.rs_lightVectors )
		
		glActiveTexture( GL_TEXTURE0+7 )
		
		If shadowTexture<>-1 And Mojo.rs_shadowTexture
			glBindTexture( GL_TEXTURE_2D,Mojo.rs_shadowTexture.GLTexture() )
			glUniform1i( shadowTexture,7 )
		Else
			glBindTexture( GL_TEXTURE_2D,TTexture.White().GLTexture() )
		End If
		
		glActiveTexture( GL_TEXTURE0 )
	End Method
End Struct

Public

Type TShader

	Method New( source:String )
		Build( source )
	End Method
	
	Method DefaultMaterial:TMaterial()
		If Not _defaultMaterial Then _defaultMaterial=New TMaterial( Self )
		Return _defaultMaterial
	End Method
	
	Function FastShader:TShader()
		Return Mojo._fastShader
	End Function
	
	Rem
	bbdoc: Returns a stock bump shader for drawing lit sprites with specular and normal maps.
	about: 
The following material properties are supported:

| @Property			| @Type		| @Default
| ColorTexture		| Texture	| White
| SpecularTexture	| Texture	| Black
| NormalTexture		| Texture	| Flat
| AmbientColor		| Float[4]	| [0.0,0.0,0.0,1.0]
| Roughness			| Float		| 0.5

The shader b3d_Ambient value is computed by multiplying ColorTexture by AmbientColor.

The shader b3d_Diffuse value is computed by multiplying ColorTexture by 1-AmbientColor.

When loading materials that use the bump shader, diffuse, specular and normal maps can be given the following files names:

| @Texture map		| @Valid paths
| Diffuse			| (FILE).(EXT) ; (FILE)_d.(EXT) ; (FILE)_diff.(EXT) ; (FILE)_diffuse.(EXT)
| Specular			| (FILE)_s.(EXT) ; (FILE)_spec.(EXT) ; (FILE)_specular.(EXT) ;(FILE)_SPECUALR.(EXT)
| Normal			| (FILE)_n.(EXT) ; (FILE)_norm.(EXT) ; (FILE)_normal.(EXT) ; (FILE)_NORMALS.(EXT)

Where (FILE) is the filename component of the path provided to Material.Load or Image.Load, and (EXT) is the file extension, eg: png, jpg.
	end rem
	Function BumpShader:TShader()
		Return Mojo._bumpShader
	End Function
	
	Rem
	bbdoc: Returns a stock matte shader for drawing lit sprites with no specular or normal maps.
	about: 
The following material properties are supported:

| @Property			| @Type		| @Default
| ColorTexture		| Texture	| White
| AmbientColor		| Float[4]	| [0.0,0.0,0.0,1.0]
| Roughness			| Float		| 0.5
	end rem
	Function MatteShader:TShader()
		Return Mojo._matteShader
	End Function
	
	Rem
	bbdoc: Returns a stock shadow shader for drawing shadows.
	about: This shader simply writes 'black' to b3d_FragColor.
	end rem
	Function ShadowShader:TShader()
		Return Mojo._shadowShader
	End Function
	
	Rem
	bbdoc: Returns a stock shader for drawing light textures and light mask effects.
	about: 
This shader performs a texture lookup, and writes the red component to b3d_FragColor.
	
The following material properties are supported:

| @Property			| @Type		| @Default
| ColorTexture		| Texture	| White
	end rem	
	Function LightMapShader:TShader()
		Return Mojo._lightMapShader
	End Function
	
	Rem
	bbdoc: Returns the default shader used when a material is created with a 'Null' shader.
	about: This is initially the #BumpShader, but can be modified using #SetDefaultShader.
	end rem
	Function DefaultShader:TShader()
		Return Mojo._defaultShader
	End Function
	
	Rem
	bbdoc: Sets the default shader used when a material is created with a 'Null' shader.
	end rem
	Function DefaultShader( shader:TShader )
		If Not shader Then shader=Mojo._bumpShader
		Mojo._defaultShader=shader
	End Function
	
	Protected
	
	Rem
	bbdoc: Compiles and links the shader.
	about: Types that extend Shader must call this method at some point. This is usually done in the subclasses constructor.
	end rem
	Method Build( source:String )
		_source=source
		BuildInit()
	End Method
	
	Rem
	bbdoc: Types that extend Shader must set defalut values for all valid shader parameters in this method.
	end rem
	Method OnInitMaterial( material:TMaterial )
		material.SetTexture( "ColorTexture",TTexture.White() )
	End Method
	
	Rem
	bbdoc: Classes that extend Shader should load textures and other valid shader parameters from @path into @material in this method.
	about: The interpretation of @path is completely up to the shader. The @texFlags parameter contains texture flag values that should be used for any textures loaded.
	The @material parameter is an already initialized material.
	This method should return @material if successful, or null on failure.
	end rem
	Method OnLoadMaterial:TMaterial( material:TMaterial,url:Object,texFlags:Int )
		Local texture:TTexture=TTexture.Load( url,texFlags )
		If Not texture Then Return Null
		material.SetTexture( "ColorTexture",texture )
		If texture Then texture.Free()
		Return material
	End Method
	
	Private
	
	Const MAX_FLAGS:Int=8
	
	'Field _seq:Int
	Field _source:String
	
	Field _vsource:String
	Field _fsource:String

	'Field _uniforms:TStringMap=New TStringMap
	Field _uniforms:THash=New THash
	
	Field _glPrograms:SGLProgram[MAX_LIGHTS+1]
	
	Field _defaultMaterial:TMaterial
	
	Method Bind()
		Local program:SGLProgram=GLProgram()
		
		If program.program=Mojo.rs_program.program Then Return

		Mojo.rs_program=program
		Mojo.rs_material=Null
		
		program.Bind()
	End Method
	
	Method GLProgram:SGLProgram()
	
		'If _seq<>Mojo.graphicsSeq 
		'	_seq=Mojo.graphicsSeq
		'	Mojo.rs_program=Null
		'	BuildInit()
		'EndIf
		
		Return _glPrograms[Mojo.rs_numLights]
	End Method
	
	Method BuildProgram:SGLProgram( numLights:Int )

		Local defs:String=""
		defs:+"#define NUM_LIGHTS "+numLights+"~n"

		Local vshader:Int=glCompile( GL_VERTEX_SHADER,defs+_vsource )
		Local fshader:Int=glCompile( GL_FRAGMENT_SHADER,defs+_fsource )
		
		Local program:Int=glCreateProgram()
		glAttachShader( program,vshader )
		glAttachShader( program,fshader )
		glDeleteShader( vshader )
		glDeleteShader( fshader )
		
		glBindAttribLocation( program,0,"Position" )
		glBindAttribLocation( program,1,"Texcoord0" )
		glBindAttribLocation( program,2,"Tangent" )
		glBindAttribLocation( program,3,"Color" )
		
		glLink( program )
		
		'enumerate program uniforms	
		Local matuniforms:SGLUniform[0] '=New TGLUniform[0]
		Local size:Int
		Local kind:Int
		Local buf:Byte[1024]
		Local l:Int
		Local n:Int
		glGetProgramiv( program,GL_ACTIVE_UNIFORMS,Varptr n )
		For Local i:Int=0 Until n
			glGetActiveUniform( program,i,1024,Varptr l,Varptr size,Varptr kind,buf )
			Local name:String = String.FromBytes( buf,l )
			If _uniforms[name]<>Null '.Contains( name )
				Local location:Int=glGetUniformLocation( program,name )
				If location=-1 Continue  'IE fix...
				matuniforms:+[New SGLUniform( name,location,size,kind )]
'				Print name[0]+"->"+location
			EndIf
		Next
		
		Return New SGLProgram( program,matuniforms )
	End Method
	
	Method BuildInit()
		'InitMojo()
		Mojo.Init()
		
		Local p:TGlslParser=New TGlslParser( _source )

		'Local vars:TMap=New TMap
		Local vars:THash=New THash
		
		While p.Toke()
		
			If p.CParse( "uniform" )
				'uniform decl
				Local ty:String=p.ParseType()
				Local id:String=p.ParseIdent()
				p.ParseToke ";"
				'_uniforms.Insert id, id
				_uniforms[id]=id
				'Print "uniform "+ty+" "+id+";"
				Continue
			EndIf
			
			Local id:String=p.CParseIdent()
			If id
				If id.StartsWith( "gl_" )
					'vars.Insert "B3D_"+id.ToUpper(), ""
					vars["B3D_"+id.ToUpper()]=" "
				Else If id.StartsWith( "b3d_" ) 
					'vars.Insert id.ToUpper(), ""
					vars[id.ToUpper()]=" "
				EndIf
				Continue
			EndIf
			
			p.Bump()
		Wend
		
		Local vardefs:String=""
		For Local v:String=EachIn vars.Keys()
			vardefs:+"#define "+v+" 1~n"
		Next
		
'		Print "Vardefs:";Print vardefs
		
		Local source:String=Mojo.mainShader
		Local i0:Int=source.Find( "//@vertex" )
		If i0=-1 Throw "Can't find //@vertex chunk"
		Local i1:Int=source.Find( "//@fragment" )
		If i1=-1 Throw "Can't find //@fragment chunk"
		
		Local header:String=vardefs+source[..i0]
		_vsource=header+source[i0..i1]
		_fsource=header+source[i1..].Replace( "${SHADER}",_source )
		
		For Local numLights:Int=0 To MAX_LIGHTS
		
			_glPrograms[numLights]=BuildProgram( numLights )

			'If numLights Or vars.Contains( "B3D_DIFFUSE" ) Or vars.Contains( "B3D_SPECULAR" ) Continue
			If numLights Or vars["B3D_DIFFUSE"]<>Null Or vars["B3D_SPECULAR"]<>Null Then Continue
			
			For Local i:Int=1 To MAX_LIGHTS
				_glPrograms[i]=_glPrograms[0]
			Next
			
			Exit
			
		Next
	End Method
End Type

Type TBumpShader Extends TShader

	Protected
	
	Method OnInitMaterial( material:TMaterial ) Override
		material.SetTexture( "ColorTexture",TTexture.White() )
		material.SetTexture( "SpecularTexture",TTexture.Black() )
		material.SetTexture( "NormalTexture",TTexture.Flat() )
		material.SetVector( "AmbientColor",[1.0,1.0,1.0,1.0] )
		material.SetScalar( "Roughness",1.0 )
	End Method
	
	Method OnLoadMaterial:TMaterial( material:TMaterial,url:Object,texFlags:Int ) Override
	
		Local path:String = String( url )
	
		Local colorTex:TTexture
		Local specularTex:TTexture
		Local normalTex:TTexture
	
		If Not path Then
			colorTex=TTexture.Load( url,texFlags )
		Else
			Local ext:String = ExtractExt( path )
			If ext path=StripExt( path ) Else ext="png"
			
			colorTex=TTexture.Load( path+"."+ext,texFlags )
			If Not colorTex colorTex=TTexture.Load( path+"_d."+ext,texFlags )
			If Not colorTex colorTex=TTexture.Load( path+"_diff."+ext,texFlags )
			If Not colorTex colorTex=TTexture.Load( path+"_diffuse."+ext,texFlags )
			
			specularTex = TTexture.Load( path+"_s."+ext,texFlags )
			If Not specularTex specularTex=TTexture.Load( path+"_spec."+ext,texFlags )
			If Not specularTex specularTex=TTexture.Load( path+"_specular."+ext,texFlags )
			If Not specularTex specularTex=TTexture.Load( path+"_SPECULAR."+ext,texFlags )
			
			normalTex = TTexture.Load( path+"_n."+ext,texFlags )
			If Not normalTex normalTex=TTexture.Load( path+"_norm."+ext,texFlags )
			If Not normalTex normalTex=TTexture.Load( path+"_normal."+ext,texFlags )
			If Not normalTex normalTex=TTexture.Load( path+"_NORMALS."+ext,texFlags )
		End If
		
		If Not colorTex And Not specularTex And Not normalTex Then Return Null

		material.SetTexture( "ColorTexture",colorTex )
		material.SetTexture( "SpecularTexture",specularTex )
		material.SetTexture( "NormalTexture",normalTex )
		
		If specularTex Or normalTex
			material.SetVector( "AmbientColor",[0.0,0.0,0.0,1.0] )
			material.SetScalar( "Roughness",.5 )
		EndIf
		
		If colorTex Then colorTex.Free()
		If specularTex Then specularTex.Free()
		If normalTex Then normalTex.Free()
		
		Return material
	End Method
End	Type

Type TMatteShader Extends TShader
	
	Protected 
	
	Method OnInitMaterial( material:TMaterial ) Override
		material.SetTexture( "ColorTexture",TTexture.White() )
		material.SetVector( "AmbientColor",[0.0,0.0,0.0,1.0] )
		material.SetScalar( "Roughness",1.0 )
	End Method
End Type
