using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveSimple : MonoBehaviour
{
    public float Speed = 1f;

    public void Update()
    {
        transform.position += transform.up * Speed * Time.deltaTime;
    }
}
