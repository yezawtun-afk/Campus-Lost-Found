using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CampusLostFound
{
    /// <summary>
    /// Small data-access helper shared by every page.
    /// All SQL goes through parameterised commands (never string concatenation).
    /// </summary>
    public static class DbHelper
    {
        // Reads the "LostFoundDB" connection string from Web.config.
        private static string ConnectionString
        {
            get
            {
                ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["LostFoundDB"];
                if (settings == null || string.IsNullOrWhiteSpace(settings.ConnectionString))
                {
                    throw new InvalidOperationException("The LostFoundDB connection string is missing from Web.config.");
                }
                return settings.ConnectionString;
            }
        }

        /// <summary>
        /// Opens and returns a new SQL connection. The caller is responsible for disposing it.
        /// </summary>
        public static SqlConnection GetConnection()
        {
            SqlConnection connection = new SqlConnection(ConnectionString);
            connection.Open();
            return connection;
        }

        /// <summary>
        /// Runs a SELECT and returns the rows as a DataTable (used to bind Repeaters and GridViews).
        /// </summary>
        public static DataTable ExecuteQuery(string sql, params SqlParameter[] parameters)
        {
            DataTable table = new DataTable();

            using (SqlConnection connection = GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    command.Parameters.AddRange(parameters);
                }

                using (SqlDataAdapter adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(table);
                }
            }

            return table;
        }

        /// <summary>
        /// Runs an INSERT / UPDATE / DELETE and returns the number of affected rows.
        /// </summary>
        public static int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection connection = GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    command.Parameters.AddRange(parameters);
                }

                return command.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Runs a statement that returns a single value (for example SCOPE_IDENTITY()).
        /// Returns null when the query returns no value.
        /// </summary>
        public static object ExecuteScalar(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection connection = GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    command.Parameters.AddRange(parameters);
                }

                object result = command.ExecuteScalar();
                return result == DBNull.Value ? null : result;
            }
        }

        /// <summary>
        /// Returns a friendly, student-safe message for a database problem (never the raw exception text).
        /// </summary>
        public static string FriendlyError(Exception ex)
        {
            SqlException sqlEx = ex as SqlException;
            if (sqlEx != null)
            {
                if (sqlEx.Number == -1 || sqlEx.Number == 2 || sqlEx.Number == 26 || sqlEx.Number == 4060)
                {
                    return "We could not connect to the database. Please make sure the LostFoundDB database has been created (see README.txt) and try again.";
                }
                return "Something went wrong while saving to the database. Please try again in a moment.";
            }

            return "Sorry, something went wrong. Please try again.";
        }
    }
}
