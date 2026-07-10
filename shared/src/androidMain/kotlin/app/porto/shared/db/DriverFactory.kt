package app.porto.shared.db

import app.porto.db.Porto
import com.squareup.sqldelight.db.SqlDriver
import com.squareup.sqldelight.driver.android.AndroidSqliteDriver

actual class DriverFactory(private val context: android.content.Context) {
    actual fun getDriver(): SqlDriver {
        return AndroidSqliteDriver(Porto.Schema, context, "porto.db")
    }
}
