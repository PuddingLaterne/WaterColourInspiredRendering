using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public GameObject Projectile;

    public float MoveSpeed = 20;
    public float DashSpeed = 5;
    public float DashTargetThreshold = 0.05f;

    private Vector2? dashTarget;
    private Vector2 moveDirection;
    private Rigidbody2D rb;

    public void Start()
    {
        rb = GetComponent<Rigidbody2D>();
    }

    public void Update()
    {
        Vector2 cursorPos = Camera.main.ScreenToWorldPoint(Input.mousePosition);
        Vector2 aimDirection = cursorPos - (Vector2)transform.position;
        moveDirection = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));

        transform.eulerAngles = new Vector3(0f, 0f, aimDirection.GetAngle());

        if(Input.GetMouseButtonDown(1))
        {
            dashTarget = cursorPos;
        }

        if (Input.GetMouseButtonDown(0))
        {
            GameObject projectile = Instantiate(Projectile);
            projectile.transform.position = (Vector2)transform.position + aimDirection * 0.1f;
            projectile.transform.eulerAngles = transform.eulerAngles;
            projectile.SetActive(true);
        }
    }

    public void FixedUpdate()
    {
        Vector2 dashVelocity = Vector2.zero;
        Vector2 moveVelocity = moveDirection * MoveSpeed;
        if (dashTarget != null)
        {
            Vector2 direction = dashTarget.Value - (Vector2)transform.position;
            dashVelocity = direction * DashSpeed;
            if(direction.magnitude <= DashTargetThreshold || dashVelocity.magnitude < moveVelocity.magnitude)
            {
                dashTarget = null;
            }
        }
        rb.velocity = dashVelocity.magnitude > moveVelocity.magnitude ? dashVelocity : moveVelocity;
    }
}
