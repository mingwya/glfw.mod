'
' NOTE : Generated file. Do not edit. Your changes may be lost on the next update!
'        Generated by g2bmx on 21 Mar 2020
'
Strict

Module GLFW.OpenGL

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Milan Ikits, Marcelo Magallon"
ModuleInfo "License: SGI Free Software License B"
ModuleInfo "Copyright: Milan Ikits, Marcelo Magallon"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial version."

Import "../glfw.mod/glfw/deps/*.h"

Import "core.bmx"
Import "glad00.bmx"

Function glShaderSource(shader_:Int,count_:Int,source:String)
	Local s:Byte Ptr = source.ToUTF8String()
	_glShaderSource(shader_, count_, Varptr s, Null)
	MemFree s
End Function

Function glGetShaderInfoLog:String(shader:Int)
	Local buf:Byte[2048]
	Local length:Int
	_glGetShaderInfoLog(shader, 2048, Null, buf)
	Return String.FromUTF8String(buf)
End Function

Function glGetProgramInfoLog:String(program:Int)
	Local buf:Byte[2048]
	Local length:Int
	_glGetShaderInfoLog(program, 2048, Null, buf)
	Return String.FromUTF8String(buf)
End Function

Function glGetShaderSource:String(shader:Int)
	Local length:Int
	glGetShaderiv(shader, GL_SHADER_SOURCE_LENGTH, Varptr length)
	If length Then
	Local buf:Byte[length + 1]
	_glGetShaderSource(shader, length + 1, Null, buf)
	Return String.FromUTF8String(buf)
	End If
End Function

Function glGetUniformLocation(program:Int, name:String)
	Local n:Byte Ptr = name.ToUTF8String()
	Local res:Int = _glGetUniformLocation(program, n)
	MemFree(n)
	Return res
End Function
