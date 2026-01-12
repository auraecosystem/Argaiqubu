defmodule Mobilizon.Federation.ActivityPub.Types.EventsTest do
  use Mobilizon.DataCase

  import Mobilizon.Factory

  alias Mobilizon.Actors.Actor
  alias Mobilizon.Addresses.Address
  alias Mobilizon.Events
  alias Mobilizon.Events.{Event, Participant}
  alias Mobilizon.Federation.ActivityPub.Activity
  alias Mobilizon.Federation.ActivityPub.Types.Events
  alias Mobilizon.Medias.Media

  @ap_public "https://www.w3.org/ns/activitystreams#Public"

  describe "test event creation" do
    @event_begins_on "2021-07-28T15:04:22Z"
    @event_title "hey"
    @event_data %{
      title: @event_title,
      begins_on: @event_begins_on,
      options: %{timezone: "Europe/Paris", anonymous_participation: false}
    }

    test "from a simple profile" do
      %Actor{
        id: organizer_actor_id,
        name: actor_name,
        url: actor_url,
        followers_url: followers_url
      } =
        insert(:actor)

      assert {:ok, %Event{}, data} =
               Events.create(
                 Map.merge(@event_data, %{organizer_actor_id: organizer_actor_id}),
                 %{}
               )

      assert match?(
               %{
                 "actor" => ^actor_url,
                 "attributedTo" => ^actor_url,
                 "cc" => [^followers_url],
                 "object" => %{
                   "actor" => ^actor_url,
                   "anonymousParticipationEnabled" => false,
                   "attachment" => [],
                   "attributedTo" => ^actor_url,
                   "category" => nil,
                   "cc" => [^followers_url],
                   "commentsEnabled" => false,
                   "content" => nil,
                   "draft" => false,
                   "endTime" => "2021-07-28T23:59:59+02:00",
                   "ical:status" => "CONFIRMED",
                   "joinMode" => "free",
                   "maximumAttendeeCapacity" => nil,
                   "mediaType" => "text/html",
                   "name" => @event_title,
                   "repliesModerationOption" => nil,
                   "startTime" => "2021-07-28T17:04:22+02:00",
                   "status" => "CONFIRMED",
                   "eventStatus" => "EventScheduled",
                   "organizers" => %{
                     "type" => "OrganizersCollection",
                     "totalItems" => 1,
                     "items" => [
                       %{"type" => "Person", "name" => ^actor_name, "id" => ^actor_url}
                     ]
                   },
                   "timezone" => "Europe/Paris",
                   "tag" => [],
                   "to" => [@ap_public],
                   "type" => "Event"
                 },
                 "to" => [@ap_public],
                 "type" => "Create"
               },
               data
             )
    end

    test "an unlisted event" do
      %Actor{
        id: organizer_actor_id,
        name: actor_name,
        url: actor_url,
        followers_url: followers_url
      } =
        insert(:actor)

      assert {:ok, %Event{}, data} =
               Events.create(
                 Map.merge(@event_data, %{
                   organizer_actor_id: organizer_actor_id,
                   visibility: :unlisted
                 }),
                 %{}
               )

      assert match?(
               %{
                 "actor" => ^actor_url,
                 "attributedTo" => ^actor_url,
                 "cc" => [@ap_public],
                 "object" => %{
                   "actor" => ^actor_url,
                   "anonymousParticipationEnabled" => false,
                   "attachment" => [],
                   "attributedTo" => ^actor_url,
                   "category" => nil,
                   "cc" => [@ap_public],
                   "commentsEnabled" => false,
                   "content" => nil,
                   "draft" => false,
                   "endTime" => "2021-07-28T23:59:59+02:00",
                   "ical:status" => "CONFIRMED",
                   "joinMode" => "free",
                   "maximumAttendeeCapacity" => nil,
                   "mediaType" => "text/html",
                   "name" => @event_title,
                   "repliesModerationOption" => nil,
                   "startTime" => "2021-07-28T17:04:22+02:00",
                   "status" => "CONFIRMED",
                   "eventStatus" => "EventScheduled",
                   "organizers" => %{
                     "type" => "OrganizersCollection",
                     "totalItems" => 1,
                     "items" => [
                       %{"type" => "Person", "name" => ^actor_name, "id" => ^actor_url}
                     ]
                   },
                   "timezone" => "Europe/Paris",
                   "tag" => [],
                   "to" => [^followers_url],
                   "type" => "Event"
                 },
                 "to" => [^followers_url],
                 "type" => "Create"
               },
               data
             )
    end

    test "from a group member" do
      %Actor{
        id: organizer_actor_id,
        name: actor_name,
        url: actor_url,
        followers_url: actor_followers_url
      } =
        actor = insert(:actor)

      %Actor{
        id: attributed_to_id,
        name: group_name,
        url: group_url,
        followers_url: followers_url,
        members_url: members_url
      } = group = insert(:group, domain: "somewhere.else", url: "https://somewhere.else/@someone")

      insert(:member, parent: group, actor: actor, role: :moderator)

      assert {:ok, %Event{}, data} =
               Events.create(
                 Map.merge(@event_data, %{
                   organizer_actor_id: organizer_actor_id,
                   attributed_to_id: attributed_to_id
                 }),
                 %{}
               )

      assert match?(
               %{
                 "actor" => ^actor_url,
                 "attributedTo" => ^group_url,
                 "cc" => [^members_url, ^followers_url],
                 "object" => %{
                   "actor" => ^actor_url,
                   "anonymousParticipationEnabled" => false,
                   "attachment" => [],
                   "attributedTo" => ^group_url,
                   "category" => nil,
                   "cc" => [^actor_followers_url],
                   "commentsEnabled" => false,
                   "content" => nil,
                   "draft" => false,
                   "endTime" => "2021-07-28T23:59:59+02:00",
                   "ical:status" => "CONFIRMED",
                   "joinMode" => "free",
                   "maximumAttendeeCapacity" => nil,
                   "mediaType" => "text/html",
                   "name" => @event_title,
                   "repliesModerationOption" => nil,
                   "startTime" => "2021-07-28T17:04:22+02:00",
                   "status" => "CONFIRMED",
                   "eventStatus" => "EventScheduled",
                   "organizers" => %{
                     "type" => "OrganizersCollection",
                     "totalItems" => 2,
                     "items" => [
                       %{"type" => "Organization", "name" => ^group_name, "id" => ^group_url},
                       %{"type" => "Person", "name" => ^actor_name, "id" => ^actor_url}
                     ]
                   },
                   "timezone" => "Europe/Paris",
                   "tag" => [],
                   "to" => [@ap_public],
                   "type" => "Event"
                 },
                 "to" => [@ap_public],
                 "type" => "Create"
               },
               data
             )
    end

    test "event physical" do
      %Actor{
        id: organizer_actor_id,
        name: actor_name,
        url: actor_url,
        followers_url: followers_url
      } =
        insert(:actor)

      geom = %Geo.Point{coordinates: {37.71, 55.67}, srid: 4326}

      %Address{
        id: address_url
      } =
        address =
        insert(:address,
          geom: geom,
          country: "France",
          locality: "Lyon",
          region: "Auvergne-Rhone-Alpes",
          description: "Centre de Lyon",
          postal_code: "69002",
          street: "place Bellecours"
        )

      assert {:ok, %Event{}, data} =
               Events.create(
                 Map.merge(@event_data, %{
                   organizer_actor_id: organizer_actor_id,
                   physical_address: address
                 }),
                 %{}
               )

      assert match?(
               %{
                 "actor" => ^actor_url,
                 "attributedTo" => ^actor_url,
                 "cc" => [^followers_url],
                 "object" => %{
                   "actor" => ^actor_url,
                   "anonymousParticipationEnabled" => false,
                   "attachment" => [],
                   "attributedTo" => ^actor_url,
                   "category" => nil,
                   "cc" => [^followers_url],
                   "commentsEnabled" => false,
                   "content" => nil,
                   "draft" => false,
                   "endTime" => "2021-07-28T23:59:59+02:00",
                   "ical:status" => "CONFIRMED",
                   "joinMode" => "free",
                   "maximumAttendeeCapacity" => nil,
                   "mediaType" => "text/html",
                   "name" => @event_title,
                   "repliesModerationOption" => nil,
                   "startTime" => "2021-07-28T17:04:22+02:00",
                   "status" => "CONFIRMED",
                   "eventStatus" => "EventScheduled",
                   "organizers" => %{
                     "type" => "OrganizersCollection",
                     "totalItems" => 1,
                     "items" => [
                       %{"type" => "Person", "name" => ^actor_name, "id" => ^actor_url}
                     ]
                   },
                   "timezone" => "Europe/Paris",
                   "location" => %{
                     "longitude" => 37.71,
                     "latitude" => 55.67,
                     "address" => %{
                       "addressCountry" => "France",
                       "addressLocality" => "Lyon",
                       "addressRegion" => "Auvergne-Rhone-Alpes",
                       "postalCode" => "69002",
                       "streetAddress" => "place Bellecours",
                       "type" => "PostalAddress"
                     },
                     "id" => address_url,
                     "name" => "Centre de Lyon",
                     "type" => "Place"
                   },
                   "tag" => [],
                   "to" => [@ap_public],
                   "type" => "Event"
                 },
                 "to" => [@ap_public],
                 "type" => "Create"
               },
               data
             )
    end

    test "event online" do
      %Actor{
        id: organizer_actor_id,
        name: actor_name,
        url: actor_url,
        followers_url: followers_url
      } =
        insert(:actor)

      assert {:ok, %Event{}, data} =
               Events.create(
                 Map.merge(@event_data, %{
                   organizer_actor_id: organizer_actor_id,
                   online_address: "https://visio.test/mobilizon"
                 }),
                 %{}
               )

      assert match?(
               %{
                 "actor" => ^actor_url,
                 "attributedTo" => ^actor_url,
                 "cc" => [^followers_url],
                 "object" => %{
                   "actor" => ^actor_url,
                   "anonymousParticipationEnabled" => false,
                   "attachment" => [
                     %{
                       "type" => "Link",
                       "href" => "https://visio.test/mobilizon",
                       "mediaType" => "text/html",
                       "name" => "Website"
                     }
                   ],
                   "attributedTo" => ^actor_url,
                   "category" => nil,
                   "cc" => [^followers_url],
                   "commentsEnabled" => false,
                   "content" => nil,
                   "draft" => false,
                   "endTime" => "2021-07-28T23:59:59+02:00",
                   "ical:status" => "CONFIRMED",
                   "joinMode" => "free",
                   "maximumAttendeeCapacity" => nil,
                   "mediaType" => "text/html",
                   "name" => @event_title,
                   "repliesModerationOption" => nil,
                   "startTime" => "2021-07-28T17:04:22+02:00",
                   "status" => "CONFIRMED",
                   "eventStatus" => "EventScheduled",
                   "location" => %{
                     "type" => "VirtualLocation",
                     "name" => "Website",
                     "url" => "https://visio.test/mobilizon"
                   },
                   "organizers" => %{
                     "type" => "OrganizersCollection",
                     "totalItems" => 1,
                     "items" => [
                       %{"type" => "Person", "name" => ^actor_name, "id" => ^actor_url}
                     ]
                   },
                   "timezone" => "Europe/Paris",
                   "tag" => [],
                   "to" => [@ap_public],
                   "type" => "Event"
                 },
                 "to" => [@ap_public],
                 "type" => "Create"
               },
               data
             )
    end

    test "event online & physical" do
      %Actor{
        id: organizer_actor_id,
        name: actor_name,
        url: actor_url,
        followers_url: followers_url
      } =
        insert(:actor)

      geom = %Geo.Point{coordinates: {37.71, 55.67}, srid: 4326}

      %Address{
        id: address_url
      } =
        address =
        insert(:address,
          geom: geom,
          country: "France",
          locality: "Lyon",
          region: "Auvergne-Rhone-Alpes",
          description: "Centre de Lyon",
          postal_code: "69002",
          street: "place Bellecours"
        )

      assert {:ok, %Event{}, data} =
               Events.create(
                 Map.merge(@event_data, %{
                   organizer_actor_id: organizer_actor_id,
                   physical_address: address,
                   online_address: "https://visio.test/mobilizon"
                 }),
                 %{}
               )

      assert match?(
               %{
                 "actor" => ^actor_url,
                 "attributedTo" => ^actor_url,
                 "cc" => [^followers_url],
                 "object" => %{
                   "actor" => ^actor_url,
                   "anonymousParticipationEnabled" => false,
                   "attachment" => [
                     %{
                       "type" => "Link",
                       "href" => "https://visio.test/mobilizon",
                       "mediaType" => "text/html",
                       "name" => "Website"
                     }
                   ],
                   "attributedTo" => ^actor_url,
                   "category" => nil,
                   "cc" => [^followers_url],
                   "commentsEnabled" => false,
                   "content" => nil,
                   "draft" => false,
                   "endTime" => "2021-07-28T23:59:59+02:00",
                   "ical:status" => "CONFIRMED",
                   "joinMode" => "free",
                   "maximumAttendeeCapacity" => nil,
                   "mediaType" => "text/html",
                   "name" => @event_title,
                   "repliesModerationOption" => nil,
                   "startTime" => "2021-07-28T17:04:22+02:00",
                   "status" => "CONFIRMED",
                   "eventStatus" => "EventScheduled",
                   "organizers" => %{
                     "type" => "OrganizersCollection",
                     "totalItems" => 1,
                     "items" => [
                       %{"type" => "Person", "name" => ^actor_name, "id" => ^actor_url}
                     ]
                   },
                   "location" => [
                     %{
                       "longitude" => 37.71,
                       "latitude" => 55.67,
                       "address" => %{
                         "addressCountry" => "France",
                         "addressLocality" => "Lyon",
                         "addressRegion" => "Auvergne-Rhone-Alpes",
                         "postalCode" => "69002",
                         "streetAddress" => "place Bellecours",
                         "type" => "PostalAddress"
                       },
                       "id" => address_url,
                       "name" => "Centre de Lyon",
                       "type" => "Place"
                     },
                     %{
                       "type" => "VirtualLocation",
                       "name" => "Website",
                       "url" => "https://visio.test/mobilizon"
                     }
                   ],
                   "timezone" => "Europe/Paris",
                   "tag" => [],
                   "to" => [@ap_public],
                   "type" => "Event"
                 },
                 "to" => [@ap_public],
                 "type" => "Create"
               },
               data
             )
    end

    test "event with inline_media" do
      %Actor{
        id: organizer_actor_id,
        name: actor_name,
        url: actor_url,
        followers_url: followers_url
      } =
        insert(:actor)

      new_image = %Mobilizon.Medias.File{
        name: "Beautifull picture",
        url: "http://mobilizon.test/beautifull_picture.png",
        content_type: "image/png",
        size: 16_907
      }

      %Media{} = media = insert(:media, file: new_image)

      assert {:ok, %Event{}, data} =
               Events.create(
                 Map.merge(@event_data, %{
                   organizer_actor_id: organizer_actor_id,
                   media: [media]
                 }),
                 %{}
               )

      assert match?(
               %{
                 "actor" => ^actor_url,
                 "attributedTo" => ^actor_url,
                 "cc" => [^followers_url],
                 "object" => %{
                   "actor" => ^actor_url,
                   "anonymousParticipationEnabled" => false,
                   "attachment" => [
                     %{
                       "type" => "Document",
                       "url" => "http://mobilizon.test/beautifull_picture.png",
                       "mediaType" => "image/png",
                       "name" => "Beautifull picture"
                     }
                   ],
                   "attributedTo" => ^actor_url,
                   "category" => nil,
                   "cc" => [^followers_url],
                   "commentsEnabled" => false,
                   "content" => nil,
                   "draft" => false,
                   "endTime" => "2021-07-28T23:59:59+02:00",
                   "ical:status" => "CONFIRMED",
                   "joinMode" => "free",
                   "maximumAttendeeCapacity" => nil,
                   "mediaType" => "text/html",
                   "name" => @event_title,
                   "repliesModerationOption" => nil,
                   "startTime" => "2021-07-28T17:04:22+02:00",
                   "status" => "CONFIRMED",
                   "eventStatus" => "EventScheduled",
                   "organizers" => %{
                     "type" => "OrganizersCollection",
                     "totalItems" => 1,
                     "items" => [
                       %{"type" => "Person", "name" => ^actor_name, "id" => ^actor_url}
                     ]
                   },
                   "timezone" => "Europe/Paris",
                   "tag" => [],
                   "to" => [@ap_public],
                   "type" => "Event"
                 },
                 "to" => [@ap_public],
                 "type" => "Create"
               },
               data
             )
    end
  end

  @event_updated_title "my event updated"
  @event_update_data %{title: @event_updated_title}

  describe "test event update" do
    test "from a simple profile" do
      %Actor{url: actor_url, name: actor_name, followers_url: followers_url} =
        actor = insert(:actor)

      {:ok, begins_on, _} = DateTime.from_iso8601(@event_begins_on)

      %Event{} =
        event = insert(:event, organizer_actor: actor, begins_on: begins_on, ends_on: nil)

      assert {:ok, %Event{}, data} =
               Events.update(
                 event,
                 @event_update_data,
                 %{}
               )

      assert match?(
               %{
                 "actor" => ^actor_url,
                 "attributedTo" => ^actor_url,
                 "cc" => [^followers_url],
                 "object" => %{
                   "actor" => ^actor_url,
                   "anonymousParticipationEnabled" => false,
                   "attributedTo" => ^actor_url,
                   "cc" => [^followers_url],
                   "commentsEnabled" => false,
                   "draft" => false,
                   "ical:status" => "CONFIRMED",
                   "joinMode" => "free",
                   "maximumAttendeeCapacity" => nil,
                   "mediaType" => "text/html",
                   "name" => @event_updated_title,
                   "repliesModerationOption" => nil,
                   "startTime" => "2021-07-28T15:04:22Z",
                   "endTime" => "2021-07-28T23:59:59Z",
                   "status" => "CONFIRMED",
                   "eventStatus" => "EventScheduled",
                   "organizers" => %{
                     "type" => "OrganizersCollection",
                     "totalItems" => 1,
                     "items" => [
                       %{"type" => "Person", "name" => ^actor_name, "id" => ^actor_url}
                     ]
                   },
                   "timezone" => "Etc/UTC",
                   "tag" => [],
                   "to" => [@ap_public],
                   "type" => "Event"
                 },
                 "to" => [@ap_public],
                 "type" => "Update"
               },
               data
             )
    end

    test "from a group member" do
      %Actor{url: actor_url} = actor_1 = insert(:actor)

      %Actor{
        id: organizer_actor_2_id,
        name: actor_name,
        url: actor_2_url,
        followers_url: actor_followers_url
      } =
        actor_2 = insert(:actor)

      %Actor{
        url: group_url,
        name: group_name,
        followers_url: followers_url,
        members_url: members_url
      } = group = insert(:group, domain: "somewhere.else", url: "https://somewhere.else/@someone")

      insert(:member, parent: group, actor: actor_1, role: :moderator)
      insert(:member, parent: group, actor: actor_2, role: :moderator)

      {:ok, begins_on, _} = DateTime.from_iso8601(@event_begins_on)

      %Event{} =
        event =
        insert(:event,
          organizer_actor: actor_1,
          begins_on: begins_on,
          ends_on: nil,
          attributed_to: group
        )

      assert {:ok, %Event{}, data} =
               Events.update(
                 event,
                 Map.merge(@event_update_data, %{
                   organizer_actor_id: organizer_actor_2_id
                 }),
                 %{}
               )

      assert match?(
               %{
                 "actor" => ^actor_2_url,
                 "attributedTo" => ^group_url,
                 "cc" => [^members_url, ^followers_url],
                 "object" => %{
                   "actor" => ^actor_2_url,
                   "anonymousParticipationEnabled" => false,
                   "attributedTo" => ^group_url,
                   "cc" => [^actor_followers_url],
                   "commentsEnabled" => false,
                   "draft" => false,
                   "ical:status" => "CONFIRMED",
                   "joinMode" => "free",
                   "maximumAttendeeCapacity" => nil,
                   "mediaType" => "text/html",
                   "name" => @event_updated_title,
                   "repliesModerationOption" => nil,
                   "startTime" => "2021-07-28T15:04:22Z",
                   "endTime" => "2021-07-28T23:59:59Z",
                   "status" => "CONFIRMED",
                   "eventStatus" => "EventScheduled",
                   "organizers" => %{
                     "type" => "OrganizersCollection",
                     "totalItems" => 2,
                     "items" => [
                       %{"type" => "Organization", "name" => ^group_name, "id" => ^group_url},
                       %{"type" => "Person", "name" => ^actor_name, "id" => ^actor_2_url}
                     ]
                   },
                   "timezone" => "Etc/UTC",
                   "tag" => [],
                   "to" => [@ap_public],
                   "type" => "Event"
                 },
                 "to" => [@ap_public],
                 "type" => "Update"
               },
               data
             )
    end

    test "from a remote group member" do
      %Actor{
        id: organizer_actor_1_id,
        name: actor_1_name,
        url: actor_1_url,
        followers_url: actor_followers_url
      } =
        actor_1 = insert(:actor)

      %Actor{} = actor_2 = insert(:actor)

      %Actor{
        url: group_url,
        name: actor_name,
        followers_url: followers_url,
        members_url: members_url
      } = group = insert(:group, domain: "somewhere.else", url: "https://somewhere.else/@someone")

      insert(:member, parent: group, actor: actor_1, role: :moderator)
      insert(:member, parent: group, actor: actor_2, role: :moderator)

      {:ok, begins_on, _} = DateTime.from_iso8601(@event_begins_on)

      %Event{} =
        event =
        insert(:event,
          organizer_actor: actor_2,
          begins_on: begins_on,
          ends_on: nil,
          attributed_to: group
        )

      assert {:ok, %Event{}, data} =
               Events.update(
                 event,
                 Map.merge(@event_update_data, %{
                   organizer_actor_id: organizer_actor_1_id
                 }),
                 %{}
               )

      assert match?(
               %{
                 "actor" => ^actor_1_url,
                 "attributedTo" => ^group_url,
                 "cc" => [^members_url, ^followers_url],
                 "object" => %{
                   "actor" => ^actor_1_url,
                   "anonymousParticipationEnabled" => false,
                   "attributedTo" => ^group_url,
                   "cc" => [^actor_followers_url],
                   "commentsEnabled" => false,
                   "draft" => false,
                   "ical:status" => "CONFIRMED",
                   "joinMode" => "free",
                   "maximumAttendeeCapacity" => nil,
                   "mediaType" => "text/html",
                   "name" => @event_updated_title,
                   "repliesModerationOption" => nil,
                   "startTime" => "2021-07-28T15:04:22Z",
                   "endTime" => "2021-07-28T23:59:59Z",
                   "status" => "CONFIRMED",
                   "eventStatus" => "EventScheduled",
                   "organizers" => %{
                     "type" => "OrganizersCollection",
                     "totalItems" => 2,
                     "items" => [
                       %{"type" => "Organization", "name" => ^actor_name, "id" => ^group_url},
                       %{"type" => "Person", "name" => ^actor_1_name, "id" => ^actor_1_url}
                     ]
                   },
                   "timezone" => "Etc/UTC",
                   "tag" => [],
                   "to" => [@ap_public],
                   "type" => "Event"
                 },
                 "to" => [@ap_public],
                 "type" => "Update"
               },
               data
             )
    end
  end

  describe "join an event" do
    test "simple and remote" do
      %Actor{url: organizer_actor_url} =
        organizer_actor = insert(:actor, domain: "somewhere.else")

      %Actor{url: participant_actor_url} = actor = insert(:actor, domain: nil)

      %Event{url: event_url} =
        event = insert(:event, organizer_actor: organizer_actor, local: false)

      assert {:ok, data, %Participant{}} = Events.join(event, actor, true, %{})

      assert match?(
               %{
                 "actor" => ^participant_actor_url,
                 "cc" => [],
                 "object" => ^event_url,
                 "participationMessage" => nil,
                 "to" => [^participant_actor_url, ^organizer_actor_url],
                 "type" => "Join"
               },
               data
             )
    end

    test "simple and local" do
      %Actor{url: organizer_actor_url} = organizer_actor = insert(:actor, domain: nil)

      %Actor{url: participant_actor_url} = actor = insert(:actor, domain: nil)

      %Event{url: event_url} = event = insert(:event, organizer_actor: organizer_actor)

      assert {:accept, {:ok, %Activity{data: data, local: true}, %Participant{}}} =
               Events.join(event, actor, true, %{})

      assert match?(
               %{
                 "actor" => ^organizer_actor_url,
                 "cc" => [],
                 "object" => %{
                   "actor" => ^participant_actor_url,
                   "object" => ^event_url,
                   "participationMessage" => nil,
                   "type" => "Join"
                 },
                 "to" => [^participant_actor_url, ^organizer_actor_url],
                 "type" => "Accept"
               },
               data
             )
    end

    test "group event local" do
      %Actor{url: organizer_group_url, members_url: members_url, followers_url: followers_url} =
        organizer_group = insert(:group, domain: nil)

      %Actor{url: participant_actor_url} = actor = insert(:actor, domain: nil)

      %Event{url: event_url} = event = insert(:event, attributed_to: organizer_group)

      assert {:ok, data, %Participant{}} = Events.join(event, actor, true, %{})

      assert match?(
               %{
                 "actor" => ^participant_actor_url,
                 "cc" => [^followers_url, ^members_url],
                 "object" => ^event_url,
                 "participationMessage" => nil,
                 "to" => [^participant_actor_url, ^organizer_group_url],
                 "type" => "Join"
               },
               data
             )
    end

    test "group event with organizer remote" do
      %Actor{url: organizer_group_url, members_url: members_url, followers_url: followers_url} =
        organizer_group = insert(:group, domain: nil)

      %Actor{url: _organizer_actor_url} =
        organizer_actor =
        insert(:actor, domain: "somewhere.else", url: "https://somewhere.else/@someone")

      insert(:member, parent: organizer_group, actor: organizer_actor, role: :moderator)

      %Actor{url: participant_actor_url} = actor = insert(:actor, domain: nil)

      %Event{url: event_url} =
        event =
        insert(:event,
          attributed_to: organizer_group,
          organizer_actor: organizer_actor,
          local: true
        )

      assert {:ok, data, %Participant{}} = Events.join(event, actor, true, %{})

      assert match?(
               %{
                 "actor" => ^participant_actor_url,
                 "cc" => [^followers_url, ^members_url],
                 "object" => ^event_url,
                 "participationMessage" => nil,
                 "to" => [^participant_actor_url, ^organizer_group_url],
                 "type" => "Join"
               },
               data
             )
    end
  end
end
