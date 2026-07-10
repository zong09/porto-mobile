package app.porto.shared.db

import app.porto.db.Porto
import com.squareup.sqldelight.db.SqlDriver
import com.squareup.sqldelight.driver.jdbc.JdbcDriver

actual class DriverFactory {
    actual fun getDriver(): SqlDriver {
        return JdbcDriver("jdbc:sqlite:")
    }
}
