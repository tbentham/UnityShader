Shader "unityCookie/tut/beginner/9 - Optimized" {
	Properties {
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_BumpMap ("Normal Texture", 2D) = "bump" {}
		_EmitMap ("Emission Texture", 2D) = "black" {}
		_BumpDepth ("Bump Depth", Range(0.0, 2.0)) = 1.0
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", Float) = 10.0
		_RimColor ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimPower ("Rim Power", Range(1.0, 10.0)) = 3.0
		_EmitStrength ("Emission Strength", Range(0.0, 2.0)) = 0.0
	}
	SubShader {
		Pass {
			Tags { "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// user defined variables
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			uniform sampler2D _BumpMap;
			uniform half4 _BumpMap_ST;
			uniform sampler2D _EmitMap;
			uniform half4 _EmitMap_ST;
			
			uniform fixed4 _Color;
			uniform fixed4 _SpecColor;
			uniform fixed4 _RimColor;
			
			uniform half _Shininess;
			uniform half _RimPower;
			uniform fixed _BumpDepth;
			uniform fixed _EmitStrength;
			
			// unity defined variables
			uniform half4 _LightColor0;
			
			// base input structs
			struct vertexInput{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 texCoord : TEXCOORD0;
				half4 tangent : TANGENT;
			};
			struct vertexOutput{
				half4 pos : SV_POSITION;
				half4 tex : TEXCOORD0;
				fixed3 lightDirection : TEXCOORD1;
				fixed3 viewDirection : TEXCOORD2;
				fixed3 normalWorld : TEXCOORD3;
				fixed3 tangentWorld : TEXCOORD4;
				fixed3 biNormalWorld : TEXCOORD5;
				half atten : TEXCOORD6;
			};
			
			// vertex function
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				
				half4 posWorld = mul( _Object2World, v.vertex );
				
				o.normalWorld = normalize( mul( _Object2World, half4(v.normal, 0.0) ).xyz );
				o.tangentWorld = normalize( mul( _Object2World, half4(v.tangent.xyz,0.0) ).xyz );
				o.biNormalWorld = normalize( cross( o.normalWorld, o.tangentWorld) * v.tangent );
				
				o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
				o.tex = v.texCoord;
				
				o.viewDirection = normalize( _WorldSpaceCameraPos.xyz - posWorld.xyz );
				
				half3 fragToLightSrc = _WorldSpaceLightPos0.xyz - posWorld.xyz;
				o.lightDirection =
					normalize( lerp(_WorldSpaceLightPos0.xyz, fragToLightSrc, _WorldSpaceLightPos0.w) );
				o.atten = lerp( 1.0, 1.0 / length(fragToLightSrc), _WorldSpaceLightPos0.w );
				
				return o;
			}
			
			// fragment function
			fixed4 frag(vertexOutput i) : COLOR
			{
				// texture maps
				fixed4 tex = tex2D( _MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw );
				fixed4 texN = tex2D( _BumpMap, i.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw );
				fixed4 texE = tex2D( _EmitMap, i.tex.xy * _EmitMap_ST.xy + _EmitMap_ST.zw );
				
				// unpackNormal function
				fixed3 localCoords = fixed3( 2.0 * texN.ag - fixed2(1.0,1.0), _BumpDepth );
				
				// normal transpose matrix
				fixed3x3 local2WorldTranspose = fixed3x3(
					i.tangentWorld,
					i.biNormalWorld,
					i.normalWorld
				);
				
				// normal direction
				fixed3 normalDirection = normalize( mul(localCoords, local2WorldTranspose) );
				
				// lighting
				fixed3 diffuseReflection = i.atten * _LightColor0.xyz
					* saturate( dot(normalDirection, i.lightDirection) );
				fixed3 specularReflection = diffuseReflection * _SpecColor.xyz
					* pow(
						saturate ( dot( reflect(-i.lightDirection, normalDirection), i.viewDirection ) ),
						_Shininess
					);
				
				// rim lighting
				fixed rim = 1 - saturate( dot(i.viewDirection, normalDirection) );
				fixed3 rimLighting = diffuseReflection * _RimColor.xyz * pow( rim, _RimPower );
				
				fixed3 lightFinal = i.atten * UNITY_LIGHTMODEL_AMBIENT.xyz + diffuseReflection
					+ tex.a * specularReflection + rimLighting + texE.xyz * _EmitStrength;
				
				return fixed4( lightFinal * tex.xyz * _Color.xyz, 1.0 );
			}
			
			ENDCG
		}
		Pass {
			Tags { "LightMode" = "ForwardAdd" }
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// user defined variables
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			uniform sampler2D _BumpMap;
			uniform half4 _BumpMap_ST;
			uniform sampler2D _EmitMap;
			uniform half4 _EmitMap_ST;
			
			uniform fixed4 _Color;
			uniform fixed4 _SpecColor;
			uniform fixed4 _RimColor;
			
			uniform half _Shininess;
			uniform half _RimPower;
			uniform fixed _BumpDepth;
			uniform fixed _EmitStrength;
			
			// unity defined variables
			uniform half4 _LightColor0;
			
			// base input structs
			struct vertexInput{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 texCoord : TEXCOORD0;
				half4 tangent : TANGENT;
			};
			struct vertexOutput{
				half4 pos : SV_POSITION;
				half4 tex : TEXCOORD0;
				fixed3 lightDirection : TEXCOORD1;
				fixed3 viewDirection : TEXCOORD2;
				fixed3 normalWorld : TEXCOORD3;
				fixed3 tangentWorld : TEXCOORD4;
				fixed3 biNormalWorld : TEXCOORD5;
				half atten : TEXCOORD6;
			};
			
			// vertex function
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				
				half4 posWorld = mul( _Object2World, v.vertex );
				
				o.normalWorld = normalize( mul( _Object2World, half4(v.normal, 0.0) ).xyz );
				o.tangentWorld = normalize( mul( _Object2World, half4(v.tangent.xyz,0.0) ).xyz );
				o.biNormalWorld = normalize( cross( o.normalWorld, o.tangentWorld) * v.tangent );
				
				o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
				o.tex = v.texCoord;
				
				o.viewDirection = normalize( _WorldSpaceCameraPos.xyz - posWorld.xyz );
				
				half3 fragToLightSrc = _WorldSpaceLightPos0.xyz - posWorld.xyz;
				o.lightDirection =
					normalize( lerp(_WorldSpaceLightPos0.xyz, fragToLightSrc, _WorldSpaceLightPos0.w) );
				o.atten = lerp( 1.0, 1.0 / length(fragToLightSrc), _WorldSpaceLightPos0.w );
				
				return o;
			}
			
			// fragment function
			fixed4 frag(vertexOutput i) : COLOR
			{
				// texture maps
				fixed4 tex = tex2D( _MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw );
				fixed4 texN = tex2D( _BumpMap, i.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw );
				fixed4 texE = tex2D( _EmitMap, i.tex.xy * _EmitMap_ST.xy + _EmitMap_ST.zw );
				
				// unpackNormal function
				fixed3 localCoords = fixed3( 2.0 * texN.ag - fixed2(1.0,1.0), _BumpDepth );
				
				// normal transpose matrix
				fixed3x3 local2WorldTranspose = fixed3x3(
					i.tangentWorld,
					i.biNormalWorld,
					i.normalWorld
				);
				
				// normal direction
				fixed3 normalDirection = normalize( mul(localCoords, local2WorldTranspose) );
				
				// lighting
				fixed3 diffuseReflection = i.atten * _LightColor0.xyz
					* saturate( dot(normalDirection, i.lightDirection) );
				fixed3 specularReflection = diffuseReflection * _SpecColor.xyz
					* pow(
						saturate ( dot( reflect(-i.lightDirection, normalDirection), i.viewDirection ) ),
						_Shininess
					);
				
				// rim lighting
				fixed rim = 1 - saturate( dot(i.viewDirection, normalDirection) );
				fixed3 rimLighting = diffuseReflection * _RimColor.xyz * pow( rim, _RimPower );
				
				fixed3 lightFinal = i.atten * UNITY_LIGHTMODEL_AMBIENT.xyz + diffuseReflection
					+ tex.a * specularReflection + rimLighting;
				
				return fixed4( lightFinal * tex.xyz * _Color.xyz, 1.0 );
			}
			
			ENDCG
		}
	}
	//Fallback "Specular"
}