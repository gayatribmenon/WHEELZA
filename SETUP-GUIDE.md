# WHEELZA setup guide (about 20 minutes, one time)

You will connect the site to a free Supabase database. After this, registrations, the admin login,
car details and car photos all work from your website, with no code editing.

## 1. Create the Supabase project
1. Go to supabase.com, sign in with GitHub, click New project.
2. Name it `wheelza`, save the database password somewhere safe, pick a region near India (Mumbai or Singapore), Free plan, Create.

## 2. Run the setup file
1. In Supabase click SQL Editor, then New query.
2. Open `supabase-setup.sql` from this folder, copy everything, paste it in, click Run. You should see "Success".

## 3. Create the WHEELZA admin login
1. Click Authentication, then Users, then Add user, then Create new user.
2. Email:  wheelza@example.com   (this is a hidden helper address. It never receives email.)
3. Password: choose a strong one that only you know. Tick "Auto Confirm User". Create.
4. Still under Authentication, open Sign In / Providers (or Settings) and turn OFF "Allow new users to sign up". This is important.
Your login on the site is then: Name = WHEELZA, Password = the one you just chose.

## 4. Connect the site
1. In Supabase open Project Settings, then API Keys (or "Data API").
2. Copy the Project URL (https://xxxx.supabase.co) and the publishable key (also called anon public).
3. Open `config.js` and paste them between the quotes for SUPABASE_URL and SUPABASE_KEY.
Never paste the secret / service_role key or any password into config.js.

## 5. Publish
Upload these to your GitHub repository (replace the old index.html): index.html, admin.html, config.js, supabase-setup.sql.
Keep your `cars` folder. Vercel updates by itself within a minute.

## 6. Try it
1. Open your site. The registration popup appears. Register with your own number.
2. Open  your-site-address/admin.html , log in as WHEELZA, and check the registration appears under Registrations.
3. Open Cars, tap Add new car, add details and photos, Save. It shows on the website straight away.
4. Tap Mark as sold on a car to put a SOLD badge on the website.

## Good to know
- Free Supabase projects pause after about a week with no activity. Opening the admin page now and then keeps it awake. If it pauses, click Restore in the Supabase dashboard.
- The admin page address is public but only the WHEELZA login can see or change anything.
- Registrations are personal data. Keep the admin password private and delete entries when people ask.
