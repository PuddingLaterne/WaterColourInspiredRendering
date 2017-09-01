using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraBounds : MonoBehaviour
{
	public void Start ()
    {
        var collider = GetComponent<EdgeCollider2D>();
        Vector2 topLeft = Camera.main.ScreenToWorldPoint(new Vector2(0f, Screen.height)) - Camera.main.transform.position;
        Vector2 topRight = Camera.main.ScreenToWorldPoint(new Vector2(Screen.width, Screen.height)) - Camera.main.transform.position; 
        Vector2 bottomRight = Camera.main.ScreenToWorldPoint(new Vector2(Screen.width, 0f)) - Camera.main.transform.position;
        Vector2 bottomLeft = Camera.main.ScreenToWorldPoint(new Vector2(0f, 0f)) - Camera.main.transform.position;

        collider.points = new Vector2[] { topLeft, topRight, bottomRight, bottomLeft, topLeft };
	}

}
