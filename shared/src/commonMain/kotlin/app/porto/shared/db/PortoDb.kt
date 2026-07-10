package app.porto.shared.db

import app.porto.db.Porto
import com.squareup.sqldelight.db.SqlDriver

object PortoDb {
    fun create(driver: SqlDriver): Porto {
        return Porto(driver)
    }
}
