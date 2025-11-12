import logging
import os
import json

import pyodbc
import azure.functions as func

app = func.FunctionApp()


@app.route(
    route="wishlist",                # URL path: /api/wishlist
    methods=["GET"],
    auth_level=func.AuthLevel.ANONYMOUS,
)
def get_wishlist(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("GetWishlist function processing a request.")

    conn_str = os.environ.get("SQL_CONNECTION_STRING")
    if not conn_str:
        logging.error("SQL_CONNECTION_STRING not set")
        return func.HttpResponse(
            json.dumps({"error": "SQL connection not configured"}),
            status_code=500,
            mimetype="application/json",
        )

    try:
        # Connect to Azure SQL using pyodbc
        with pyodbc.connect(conn_str) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                SELECT
                    id,
                    name,
                    price_in_aud,
                    description,
                    url,
                    image_url,
                    date_added
                FROM dbo.WishlistItem
                ORDER BY id
                """
            )

            items = []
            for row in cursor.fetchall():
                item = {
                    "id": row.id,
                    "name": row.name,
                    "price_in_aud": float(row.price_in_aud)
                    if row.price_in_aud is not None
                    else None,
                    "description": row.description,
                    "url": row.url,
                    "imageUrl": row.image_url,
                    "dateAdded": row.date_added.isoformat()
                    if row.date_added is not None
                    else None,
                }
                items.append(item)

        return func.HttpResponse(
            body=json.dumps(items),
            mimetype="application/json",
        )

    except Exception as exc:
        logging.exception("Error querying wishlist")
        return func.HttpResponse(
            json.dumps({"error": str(exc)}),
            status_code=500,
            mimetype="application/json",
        )
