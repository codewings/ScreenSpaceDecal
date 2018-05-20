using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScreenSpaceDecal : MonoBehaviour 
{
	void OnWillRenderObject()
	{
		if ((Camera.current.depthTextureMode & DepthTextureMode.Depth) == 0)
			Camera.current.depthTextureMode |= DepthTextureMode.Depth;
	}

	void OnDrawGizmos()
	{
		var oldGizmoColor = Gizmos.color;

		Gizmos.color = Color.red;
		Gizmos.DrawWireCube(transform.position, Vector3.one);

		Gizmos.color = oldGizmoColor;
	}
}
