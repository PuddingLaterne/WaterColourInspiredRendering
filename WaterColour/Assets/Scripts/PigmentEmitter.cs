using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PigmentEmitter : MonoBehaviour
{
    public AnimationCurve SizeByLifetime = AnimationCurve.Linear(0f, 0f, 1f, 1f);

    private Vector2 oldPos;
    private float lifeTime;

    public void OnEnable()
    {
        lifeTime = 0.0f;
        oldPos = transform.parent.position;
    }

    public void Update()
    {
        lifeTime += Time.deltaTime;
        Vector2 pos = transform.parent.position;
        transform.position = oldPos + (pos - oldPos) * 0.5f;
        transform.localScale = new Vector3(SizeByLifetime.Evaluate(lifeTime), Vector2.Distance(pos, oldPos) * 2.0f, 1.0f);
        oldPos = pos;
    }

}
